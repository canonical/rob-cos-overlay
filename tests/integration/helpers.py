from contextlib import contextmanager
import json
import os
import shlex
import shutil
import ssl
import subprocess
import contextlib
from pathlib import Path
from typing import Generator, List, Optional
from urllib.request import urlopen
import logging
from collections.abc import Mapping
from tenacity import retry, stop_after_delay, wait_fixed, retry_if_exception_type

import jubilant

logger = logging.getLogger(__name__)


class Retry(Exception):
    """Exception raised when we should retry"""


retry_for_10m = retry(stop=stop_after_delay(60 * 10), wait=wait_fixed(5))


def ros_domain_cloud_init_config(domain_id: int = 6) -> str:
    return (
        "#cloud-config\n"
        "write_files:\n"
        "  - path: /etc/systemd/system.conf.d/10-ros-domain.conf\n"
        "    content: |\n"
        "      [Manager]\n"
        f'      DefaultEnvironment="ROS_DOMAIN_ID={domain_id}"\n'
        "  - path: /etc/environment\n"
        "    content: |\n"
        f"      ROS_DOMAIN_ID={domain_id}\n"
        "    append: true\n"
    )


@contextlib.contextmanager
def temp_named_model(
    name: str,
    keep: bool = False,
    controller: str | None = None,
    cloud: str | None = None,
    config: Mapping[str, jubilant._juju.ConfigValue] | None = None,
    credential: str | None = None,
) -> Generator[jubilant.Juju, None, None]:
    juju = jubilant.Juju()
    juju.add_model(
        name, cloud=cloud, controller=controller, config=config, credential=credential
    )
    try:
        yield juju
    finally:
        if not keep:
            assert juju.model is not None
            try:
                # We're not using juju.destroy_model() here, as Juju doesn't provide a way
                # to specify the timeout for the entire model destruction operation.
                args = [
                    "destroy-model",
                    juju.model,
                    "--no-prompt",
                    "--destroy-storage",
                    "--force",
                ]
                juju._cli(*args, include_model=False, timeout=10 * 60)
                juju.model = None
            except subprocess.TimeoutExpired as exc:
                logger.error(
                    "timeout destroying model: %s\nStdout:\n%s\nStderr:\n%s",
                    exc,
                    exc.stdout,
                    exc.stderr,
                )


class TfDirManager:
    def __init__(self, base_tmpdir):
        self.base: str = str(base_tmpdir)
        self.dir: str = ""

    @property
    def tf_cmd(self):
        return f"terraform -chdir={self.dir}"

    def init(self, tf_file: str):
        """Initialize a Terraform module in a subdirectory."""
        self.dir = os.path.join(self.base, "terraform")
        os.makedirs(self.dir, exist_ok=True)
        repo_root = Path(__file__).resolve().parents[2]
        link_path = Path(self.dir) / "rob-cos-overlay"
        if not link_path.exists():
            link_path.symlink_to(repo_root)
        shutil.copy(tf_file, os.path.join(self.dir, "main.tf"))
        subprocess.run(shlex.split(f"{self.tf_cmd} init -upgrade"), check=True)

    @staticmethod
    def _args_str(target: Optional[str] = None, **kwargs) -> str:
        target_arg = f"-target module.{target}" if target else ""
        var_args_list = []
        for key, value in kwargs.items():
            if isinstance(value, (dict, list)):
                rendered = json.dumps(value, separators=(",", ":"))
            elif isinstance(value, bool):
                rendered = "true" if value else "false"
            else:
                rendered = str(value)
            var_args_list.append(f"-var {shlex.quote(f'{key}={rendered}')}")
        var_args = " ".join(var_args_list)
        return "-auto-approve " + f"{target_arg} " + var_args

    def apply(self, target: Optional[str] = None, **kwargs):
        cmd_str = f"{self.tf_cmd} apply " + self._args_str(target, **kwargs)
        subprocess.run(shlex.split(cmd_str), check=True)

    def destroy(self, **kwargs):
        cmd_str = f"{self.tf_cmd} destroy " + self._args_str(None, **kwargs)
        subprocess.run(shlex.split(cmd_str), check=True)


def refresh_o11y_apps(juju: jubilant.Juju, channel: str, base: Optional[str] = None):
    """Temporary workaround for the issue:

    FIXME: https://github.com/juju/terraform-provider-juju/issues/967
    TODO: The issue has been close, so let's see if we can get rid of that.
    """
    for app in juju.status().apps:
        if app in {"traefik", "ca"}:
            continue
        if "s3-integrator" in app:
            continue
        juju.refresh(app, channel=channel, base=base)


def wait_for_active_idle_without_error(
    jujus: List[jubilant.Juju], timeout: int = 60 * 45
):
    for juju in jujus:
        print(f"\nwaiting for the model ({juju.model}) to settle ...\n")
        juju.wait(jubilant.all_active, delay=10, timeout=timeout)
        print("\nwaiting for agents idle ...\n")
        juju.wait(
            jubilant.all_agents_idle,
            delay=10,
            timeout=timeout,
            error=jubilant.any_error,
        )


def get_tls_context(
    temp_path: Path, juju: jubilant.Juju, ca_name: str
) -> Optional[ssl.SSLContext]:
    if ca_name not in juju.status().apps:
        return None

    # Obtain certificate from external-ca
    cert_path = temp_path / "ca.pem"

    task = juju.run(f"{ca_name}/0", "get-ca-certificate", {"format": "json"})
    cert = task.results.get("ca-certificate")
    cert_path.write_text(cert)

    ctx = ssl.create_default_context()
    ctx.load_verify_locations(cert_path)
    return ctx


def blackbox_catalogue_ingress_fix(juju: jubilant.Juju):
    # FIXME: https://github.com/canonical/blackbox-exporter-k8s-operator/issues/74
    juju.remove_relation("blackbox-exporter:catalogue", "catalogue:catalogue")
    wait_for_active_idle_without_error([juju])
    juju.integrate("blackbox-exporter:catalogue", "catalogue:catalogue")
    wait_for_active_idle_without_error([juju])


def catalogue_apps_are_reachable(
    juju: jubilant.Juju, tls_context: Optional[ssl.SSLContext] = None
):
    stdout = juju.ssh("catalogue/0", "cat /web/config.json", container="catalogue")
    cat_conf = json.loads(stdout)
    apps = {app["name"]: app["url"] for app in cat_conf["apps"]}
    for app, url in apps.items():
        if not url:
            continue
        response = urlopen(url, data=None, timeout=2.0, context=tls_context)
        assert response.code == 200, f"{app} was not reachable"


def trigger_update_status(juju: jubilant.Juju, unit: str) -> None:
    juju._cli(
        "run",
        "--unit",
        unit,
        "--hook",
        "update-status",
    )
