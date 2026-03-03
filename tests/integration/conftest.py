#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Conftest file for integration tests."""

import os

import pytest

from helpers import ros_domain_cloud_init_config
from terraform import TfDirManager
from juju import temp_named_model
from craft_providers.lxd import LXC
from craft_providers.lxd import is_installed as is_lxd_installed
from lxd_ubuntu_core import temp_lxd_vm, import_ubuntu_core_image


@pytest.fixture(scope="module")
def ca_model():
    keep_models: bool = os.environ.get("KEEP_MODELS") is not None
    with temp_named_model(name="ca", keep=keep_models) as juju:
        yield juju


@pytest.fixture(scope="module")
def cos_model():
    keep_models: bool = os.environ.get("KEEP_MODELS") is not None
    with temp_named_model(name="cos-rob", keep=keep_models, cloud="microk8s") as juju:
        yield juju


@pytest.fixture(scope="module")
def tf_manager(tmp_path_factory):
    base = tmp_path_factory.mktemp("terraform_base")
    return TfDirManager(base)


@pytest.fixture(scope="session")
def lxc():
    """Return a craft-providers LXC wrapper instance."""
    if not is_lxd_installed():
        raise RuntimeError("lxd is not installed")
    return LXC()


@pytest.fixture(scope="session")
def ubuntu_core_image(lxc):
    """Ensure the Ubuntu Core image is imported and return its alias."""
    image_alias = "tb3c-core22"
    import_ubuntu_core_image(
        lxc,
        qcow2_url="https://github.com/ubuntu-robotics/turtlebot3c-ubuntu-core/releases/download/0.1.1-humble-virtual-cos/turtlebot3c.qcow2.tar.gz",
        alias=image_alias,
    )
    return image_alias


def keep_lxd_vms() -> bool:
    """Return whether LXD VMs should be kept after tests."""
    return os.environ.get("KEEP_LXD_VMS") is not None


@pytest.fixture(scope="module")
def robot_1_vm(ubuntu_core_image, lxc):
    """Create a shared VM for tb3-robot-1."""
    with temp_lxd_vm(
        lxc,
        name="tb3-robot-1",
        image_alias=ubuntu_core_image,
        cloud_init=ros_domain_cloud_init_config(1),
        keep=keep_lxd_vms(),
    ) as vm:
        yield vm


@pytest.fixture(scope="module")
def robot_2_vm(ubuntu_core_image, lxc):
    """Create a shared VM for tb3-robot-2."""
    with temp_lxd_vm(
        lxc,
        name="tb3-robot-2",
        image_alias=ubuntu_core_image,
        cloud_init=ros_domain_cloud_init_config(2),
        keep=keep_lxd_vms(),
    ) as vm:
        yield vm
