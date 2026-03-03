from pathlib import Path
import json

import pytest
import requests

from helpers import (
    retry_for_10m,
    Retry,
    ros_domain_cloud_init_config,
    get_cos_registration_server_devices,
    alert_group_names,
    scrape_jobs,
    assert_with_data,
)

from juju import (
    blackbox_catalogue_ingress_fix,
    catalogue_apps_are_reachable,
    wait_for_active_idle_without_error,
    trigger_update_status,
    find_application_data,
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
        devices = get_cos_registration_server_devices()
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


def test_robot_deployed_configuration(
    cos_model: jubilant.Juju, ubuntu_core_image: str, temp_lxd_vm: LXDInstance
):
    devices = get_cos_registration_server_devices()
    assert isinstance(devices, list) and devices, "Expected at least one device"
    device_uid = devices[0].get("uid")
    device_address = devices[0].get("address")
    assert device_uid, "Expected device uid to be present"
    assert device_address, "Expected device address to be present"

    prometheus_app_data = find_application_data(
        cos_model,
        "prometheus/0",
        "metrics-endpoint",
        "cos-registration-server/0",
        "alert_rules",
    )
    prometheus_group_names = alert_group_names(prometheus_app_data["alert_rules"])
    assert_with_data(
        f"low_memory_{device_uid}_alerts" in prometheus_group_names,
        "Prometheus alert group missing for device",
        prometheus_app_data,
    )
    assert_with_data(
        "low_battery" in prometheus_group_names,
        "Prometheus low_battery alert group missing",
        prometheus_app_data,
    )

    loki_app_data = find_application_data(
        cos_model,
        "loki/0",
        "logging",
        "cos-registration-server/0",
        "alert_rules",
    )
    loki_group_names = alert_group_names(loki_app_data["alert_rules"])
    assert_with_data(
        f"human_detected/{device_uid}_alerts" in loki_group_names,
        "Loki human_detected alert group missing for device",
        loki_app_data,
    )
    assert_with_data(
        "high_log_rate_alerts" in loki_group_names,
        "Loki high_log_rate_alerts group missing",
        loki_app_data,
    )

    blackbox_app_data = find_application_data(
        cos_model,
        "blackbox-exporter/0",
        "blackbox",
        "cos-registration-server/0",
        "scrape_probes",
    )
    static_configs = scrape_jobs(blackbox_app_data["scrape_probes"])
    matching_configs = [
        config
        for config in static_configs
        if device_uid in config.get("labels", {}).values()
    ]
    assert_with_data(
        bool(matching_configs),
        "Blackbox exporter static_configs missing device UID",
        blackbox_app_data,
    )
    assert_with_data(
        any(device_address in config.get("targets", []) for config in matching_configs),
        "Blackbox exporter targets missing device address",
        blackbox_app_data,
    )

    grafana_app_data = find_application_data(
        cos_model,
        "grafana/0",
        "grafana-dashboard",
        "cos-registration-server/0",
        "dashboards",
    )
    try:
        dashboards = json.loads(grafana_app_data["dashboards"])
    except json.JSONDecodeError as exc:
        raise AssertionError("dashboards is not valid JSON") from exc

    # We cannot check more since the values are encoded.
    assert_with_data(
        isinstance(dashboards, dict) and "templates" in dashboards,
        "Grafana dashboards missing templates from cos-registration-server",
        grafana_app_data,
    )
