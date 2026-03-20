"""Generic integration test helpers."""

import json
import logging
from typing import List

import requests
from tenacity import retry, stop_after_delay, wait_fixed, before_sleep_log

from ros2 import list_snapd_services, start_snapd_service

COS_SERVER_ADDRESS = "http://10.64.140.43"
COS_MODEL_NAME = "cos-rob"
COS_REGISTRATION_SERVER_API = (
    f"{COS_SERVER_ADDRESS}/{COS_MODEL_NAME}-cos-registration-server/api/v1/"
)
COS_REGISTRATION_SERVER_API_DEVICES = f"{COS_REGISTRATION_SERVER_API}devices/"

COS_REGISTRATION_AGENT_REGISTRATION_SERVICE_NAME = (
    "cos-registration-agent.register-device"
)
COS_REGISTRATION_AGENT_DELETION_SERVICE_NAME = "cos-registration-agent.delete-device"


logger = logging.getLogger(__name__)


class Retry(Exception):
    """Exception raised when we should retry."""


retry_for_10m = retry(
    stop=stop_after_delay(60 * 10),
    wait=wait_fixed(5),
    before_sleep=before_sleep_log(logger, logging.INFO),
)


def get_cos_registration_server_devices() -> List:
    """Return the list of devices from the registration server API."""
    response = requests.get(
        COS_REGISTRATION_SERVER_API_DEVICES,
        timeout=30,
    )
    response.raise_for_status()
    return response.json()


def ros_domain_cloud_init_config(ros_domain_id: int = 0) -> str:
    """Return cloud-init config to set ROS_DOMAIN_ID and refresh snaps."""
    return (
        "#cloud-config\n"
        "write_files:\n"
        "  - path: /etc/systemd/system.conf.d/10-ros-domain.conf\n"
        "    content: |\n"
        "      [Manager]\n"
        f'      DefaultEnvironment="ROS_DOMAIN_ID={ros_domain_id}"\n'
        "  - path: /etc/environment\n"
        "    content: |\n"
        f"      ROS_DOMAIN_ID={ros_domain_id}\n"
        "    append: true\n"
        "runcmd:\n"
        "  - snap wait system seed.loaded\n"
        "  - |\n"
        "    while snap changes | grep -q 'Doing'; do\n"
        '      echo "Waiting for all initial seeded snaps to finish installing..."\n'
        "      sleep 5\n"
        "    done\n"
        "  - snap refresh\n"
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
def cos_registration_agent_is_available(
    *,
    ros_domain_id: int = 0,
) -> None:
    """Wait until the cos-registration-agent service is listed."""
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
    ensure_snapd_service_started(
        COS_REGISTRATION_AGENT_DELETION_SERVICE_NAME,
        ros_domain_id=ros_domain_id,
    )


def ensure_snapd_service_list_contains(
    service_name: str,
    *,
    ros_domain_id: int | None = None,
) -> None:
    """Raise Retry if the snapd service list lacks the target service."""
    result = list_snapd_services(ros_domain_id=ros_domain_id)
    if service_name not in result.stdout:
        raise Retry


def ensure_snapd_service_started(
    service_name: str,
    *,
    ros_domain_id: int | None = None,
) -> None:
    """Raise Retry unless ros2_snapd start reports success."""
    result = start_snapd_service(
        service_name,
        ros_domain_id=ros_domain_id,
    )
    if "success=True" not in result.stdout:
        raise Retry


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
