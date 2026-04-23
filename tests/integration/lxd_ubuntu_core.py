import contextlib
import tarfile
import tempfile
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import urlopen
import logging

from craft_providers.lxd import LXC
from craft_providers.lxd.lxd_instance import LXDInstance

logger = logging.getLogger(__name__)


@contextlib.contextmanager
def temp_lxd_vm(
    lxc: LXC,
    *,
    name: str,
    image_alias: str,
    cloud_init: str | None = None,
    cpus: int = 2,
    memory: int = 4,
    disk: int = 10,
    keep: bool = False,
):
    """Context manager that creates and cleans up LXD VMs."""
    launch_ubuntu_core_vm(
        lxc,
        name=name,
        image_alias=image_alias,
        cloud_init=cloud_init,
        cpus=cpus,
        memory=memory,
        disk=disk,
    )
    instance = LXDInstance(
        name=name,
        project="default",
        remote="local",
        lxc=lxc,
    )
    try:
        yield instance
    finally:
        if not keep:
            lxc.delete(instance_name=name, force=True)


def create_core_profile(lxc: LXC):
    """Create the 'core' LXD profile used for Ubuntu Core VMs."""
    profile_config = {
        "name": "core",
        "description": "LXD profile for Ubuntu Core VMs",
        "config": {
            "cloud-init.vendor-data": """#cloud-config
users:
  - name: ubuntu
    homedir: /home/ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    plain_text_passwd: ubuntu
    lock_passwd: False
chpasswd:
  expire: False
""",
        },
        "devices": {
            "cloudinit": {
                "source": "cloud-init:config",
                "type": "disk",
            }
        },
    }

    # create a clean core profile
    lxc._run_lxc(["profile", "delete", "core"], check=False)
    lxc._run_lxc(["profile", "create", "core"])

    lxc.profile_edit(profile="core", config=profile_config)


def import_ubuntu_core_image(lxc: LXC, qcow2_url: str, alias: str):
    """Download and import a qcow2 image tarball under a given alias."""
    create_core_profile(lxc)

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        tar_path = temp_path / "ubuntu-core.qcow2.tar.gz"
        parts_dir = temp_path / "parts"
        parts_dir.mkdir(parents=True, exist_ok=True)

        try:
            with urlopen(qcow2_url) as response, tar_path.open("wb") as tar_file:
                tar_file.write(response.read())
        except HTTPError as exc:
            if exc.code != 404:
                raise
            logger.debug("Couldn't retrieve the entire tarball, trying for parts")
            part_index = 1
            downloaded_parts: list[Path] = []
            while True:
                part_url = f"{qcow2_url}.part-{part_index:03d}"
                part_path = parts_dir / f"part-{part_index:03d}"
                try:
                    with (
                        urlopen(part_url) as response,
                        part_path.open("wb") as part_file,
                    ):
                        part_file.write(response.read())
                except HTTPError as part_exc:
                    if part_exc.code == 404:
                        break
                    raise
                downloaded_parts.append(part_path)
                part_index += 1

            if not downloaded_parts:
                raise FileNotFoundError(
                    "No full tarball or split parts found for the image"
                )

            with tar_path.open("wb") as tar_file:
                for part_path in downloaded_parts:
                    tar_file.write(part_path.read_bytes())

        with tarfile.open(tar_path) as tar:
            tar.extractall(temp_path)

        metadata = next(temp_path.rglob("metadata.tar.gz"), None)
        qcow2 = next(temp_path.rglob("*.qcow2"), None)

        if metadata is None or qcow2 is None:
            raise FileNotFoundError(
                "Expected metadata.tar.gz and a .qcow2 file in the archive"
            )

        # This can fail if the image doesn't exist
        lxc._run_lxc(["image", "delete", alias], check=False)

        lxc._run_lxc(["image", "import", str(metadata), str(qcow2), "--alias", alias])


def launch_ubuntu_core_vm(
    lxc: LXC,
    name: str,
    image_alias: str,
    cloud_init: str | None = None,
    cpus: int = 4,
    memory: int = 8,
    disk: int = 20,
):
    """Launch an Ubuntu Core VM with CPU, memory, and disk limits."""
    config_args = []
    if cloud_init:
        config_args.extend(["-c", f"user.user-data={cloud_init}"])
    lxc._run_lxc(
        [
            "launch",
            image_alias,
            name,
            "--vm",
            "--profile",
            "default",
            "--profile",
            "core",
            "-c",
            f"limits.cpu={cpus}",
            "-c",
            f"limits.memory={memory}GiB",
            "-d",
            f"root,size={disk}GiB",
        ]
        + config_args
    )
