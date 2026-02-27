import os
import subprocess

from helpers import Retry


def make_env(ros_domain_id: int | None = None) -> dict[str, str]:
    """Return a process environment with an optional ROS_DOMAIN_ID override."""
    env = os.environ.copy()
    if ros_domain_id is not None:
        env["ROS_DOMAIN_ID"] = str(ros_domain_id)
    return env


def run_ros2(
    args: list[str],
    *,
    ros_domain_id: int | None = None,
    check: bool = False,
) -> subprocess.CompletedProcess[str]:
    """Run a ros2 command and return the completed process."""
    return subprocess.run(
        ["ros2", *args],
        env=make_env(ros_domain_id),
        check=check,
        capture_output=True,
        text=True,
    )


def list_services(ros_domain_id: int | None = None) -> subprocess.CompletedProcess[str]:
    """List ROS 2 services available in the current domain."""
    return run_ros2(["service", "list"], ros_domain_id=ros_domain_id)


def list_snapd_services(
    ros_domain_id: int | None = None,
) -> subprocess.CompletedProcess[str]:
    """Call ros2_snapd list service and return the response."""
    return run_ros2(
        [
            "service",
            "call",
            "/ros2_snapd/list",
            "ros2_snapd/srv/SnapdList",
        ],
        ros_domain_id=ros_domain_id,
    )


def start_snapd_service(
    service_name: str,
    *,
    ros_domain_id: int | None = None,
) -> subprocess.CompletedProcess[str]:
    """Call ros2_snapd start for a given service and return the response."""
    return run_ros2(
        [
            "service",
            "call",
            "/ros2_snapd/start",
            "ros2_snapd/srv/SnapdStart",
            f"service: '{service_name}'",
        ],
        ros_domain_id=ros_domain_id,
        check=True,
    )


def stop_snapd_service(
    service_name: str,
    *,
    ros_domain_id: int | None = None,
) -> subprocess.CompletedProcess[str]:
    """Call ros2_snapd stop for a given service and return the response."""
    return run_ros2(
        [
            "service",
            "call",
            "/ros2_snapd/stop",
            "ros2_snapd/srv/SnapdStop",
            f"service: '{service_name}'",
        ],
        ros_domain_id=ros_domain_id,
        check=True,
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
