from pathlib import Path

import pytest
import requests

from helpers import (
    blackbox_catalogue_ingress_fix,
    catalogue_apps_are_reachable,
    wait_for_active_idle_without_error,
    retry_for_10m,
    Retry,
    ros_domain_cloud_init_config,
    trigger_update_status,
)

from ros2 import (
    ensure_snapd_service_list_contains,
    ensure_snapd_service_started,
)

from craft_providers.lxd.lxd_instance import LXDInstance

from lxd_ubuntu_core import temp_lxd_vm, lxc, ubuntu_core_image

import jubilant

TRACK_LATEST_TF_FILE = Path(__file__).parent.resolve() / "track-latest.tf"


def test_deploy_reach_catalogue(tf_manager, cos_model: jubilant.Juju):
    tf_manager.init(TRACK_LATEST_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    wait_for_active_idle_without_error([cos_model])
    blackbox_catalogue_ingress_fix(cos_model)
    catalogue_apps_are_reachable(cos_model)


def test_update_track(tf_manager, cos_model: jubilant.Juju):
    cos_model.remove_relation(
        "catalogue:catalogue", "cos-registration-server:catalogue"
    )
    cos_lite_channel = {"cos_lite": {"channel": "1/candidate"}}
    wait_for_active_idle_without_error([cos_model])
    tf_manager.init(TRACK_LATEST_TF_FILE)
    tf_manager.apply(
        model=cos_model.model,
        target=None,
        **cos_lite_channel,
    )

    wait_for_active_idle_without_error([cos_model])
    catalogue_apps_are_reachable(cos_model)


def test_deploy_one_robot(
    cos_model: jubilant.Juju, ubuntu_core_image: str, temp_lxd_vm: LXDInstance
):
    robot_1 = temp_lxd_vm(
        name="tb3-robot-1",
        image_alias=ubuntu_core_image,
        cloud_init=ros_domain_cloud_init_config(1),
    )
    service_name = "cos-registration-agent.register-device"

    @retry_for_10m
    def cos_registration_agent_available(ros_domain_id: int = 0):
        ensure_snapd_service_list_contains(
            service_name,
            ros_domain_id=ros_domain_id,
        )

    @retry_for_10m
    def register_device(ros_domain_id: int = 0):
        ensure_snapd_service_started(
            service_name,
            ros_domain_id=ros_domain_id,
        )

    @retry_for_10m
    def assert_device():
        response = requests.get(
            "http://10.64.140.43/cos-rob-cos-registration-server/api/v1/devices",
            timeout=30,
        )
        response.raise_for_status()
        devices = response.json()
        assert isinstance(devices, list), "Expected devices endpoint to return a list"
        if len(devices) == 0:
            raise Retry
        assert len(devices) == 1, "Expected exactly one device to be registered"
        device_uid = devices[0].get("uid")
        assert device_uid, "Expected device uid to be present"
        return devices

    cos_registration_agent_available(ros_domain_id=1)
    register_device(ros_domain_id=1)
    assert_device()

    trigger_update_status(cos_model, "cos-registration-server/0")
