"""Generic integration test helpers."""

import json
from typing import List

import requests
from tenacity import retry, stop_after_delay, wait_fixed

COS_SERVER_ADDRESS = "http://10.64.140.43/cos-rob"
COS_REGISTRATION_SERVER_API = f"{COS_SERVER_ADDRESS}-cos-registration-server/api/v1/"
COS_REGISTRATION_SERVER_API_DEVICES = f"{COS_REGISTRATION_SERVER_API}devices/"

COS_REGISTRATION_AGENT_REGISTRATION_SERVICE_NAME = (
    "cos-registration-agent.register-device"
)
COS_REGISTRATION_AGENT_DELETION_SERVICE_NAME = "cos-registration-agent.delete-device"


class Retry(Exception):
    """Exception raised when we should retry."""


retry_for_10m = retry(stop=stop_after_delay(60 * 10), wait=wait_fixed(5))


def get_cos_registration_server_devices() -> List:
    """Return the list of devices from the registration server API."""
    response = requests.get(
        COS_REGISTRATION_SERVER_API_DEVICES,
        timeout=30,
    )
    response.raise_for_status()
    return response.json()


def ros_domain_cloud_init_config(domain_id: int = 6) -> str:
    """Return cloud-init config to set ROS_DOMAIN_ID."""
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


def alert_group_names(alert_rules: str) -> set[str]:
    """Return alert group names from alert_rules JSON."""
    try:
        parsed = json.loads(alert_rules)
    except json.JSONDecodeError as exc:
        raise AssertionError("alert_rules is not valid JSON") from exc
    groups = parsed.get("groups", []) if isinstance(parsed, dict) else []
    return {group.get("name") for group in groups if group.get("name")}


def scrape_jobs(scrape_probes: str) -> list[dict]:
    """Return static_configs entries from scrape_probes JSON."""
    try:
        parsed = json.loads(scrape_probes)
    except json.JSONDecodeError as exc:
        raise AssertionError("scrape_probes is not valid JSON") from exc
    jobs: list[dict] = []
    if isinstance(parsed, list):
        jobs = parsed
    if isinstance(parsed, dict):
        if isinstance(parsed.get("scrape_configs"), list):
            jobs = parsed["scrape_configs"]
        if isinstance(parsed.get("jobs"), list):
            jobs = parsed["jobs"]
    static_configs: list[dict] = []
    for job in jobs:
        for config in job.get("static_configs", []):
            if isinstance(config, dict):
                static_configs.append(config)
    return static_configs


def assert_with_data(condition: bool, message: str, data: object) -> None:
    """Assert condition and include formatted data on failure."""
    if condition:
        return
    try:
        rendered = json.dumps(data, indent=2, sort_keys=True, default=str)
    except (TypeError, ValueError):
        rendered = repr(data)
    raise AssertionError(f"{message}\nData:\n{rendered}")


@retry_for_10m
def cos_registration_agent_available(
    *,
    ros_domain_id: int = 0,
) -> None:
    """Wait until the cos-registration-agent service is listed."""
    from ros2 import ensure_snapd_service_list_contains

    ensure_snapd_service_list_contains(
        COS_REGISTRATION_AGENT_REGISTRATION_SERVICE_NAME,
        ros_domain_id=ros_domain_id,
    )


@retry_for_10m
def register_device(
    *,
    ros_domain_id: int = 0,
) -> None:
    """Wait until the cos-registration-agent registers the device."""
    from ros2 import ensure_snapd_service_started

    ensure_snapd_service_started(
        COS_REGISTRATION_AGENT_REGISTRATION_SERVICE_NAME,
        ros_domain_id=ros_domain_id,
    )


@retry_for_10m
def delete_device(
    *,
    ros_domain_id: int = 0,
) -> None:
    """Wait until the cos-registration-agent deletes the device."""
    from ros2 import ensure_snapd_service_started

    ensure_snapd_service_started(
        COS_REGISTRATION_AGENT_DELETION_SERVICE_NAME,
        ros_domain_id=ros_domain_id,
    )


@retry_for_10m
def assert_devices(*, expected_count: int) -> List:
    """Wait until the expected number of devices are registered."""
    devices = get_cos_registration_server_devices()
    assert isinstance(devices, list), "Expected devices endpoint to return a list"
    if expected_count == 0:
        assert len(devices) == 0, "Expected no devices to be registered"
        return devices
    if len(devices) < expected_count:
        raise Retry
    assert len(devices) == expected_count, (
        f"Expected exactly {expected_count} device(s) to be registered"
    )
    return devices
