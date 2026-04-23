"""ROS 2 helpers for integration tests."""

import os
import subprocess


def make_env(ros_domain_id: int | None = None) -> dict[str, str]:
    """Return a process environment with an optional ROS_DOMAIN_ID override."""
    env = os.environ.copy()
    if ros_domain_id is not None:
        env["ROS_DOMAIN_ID"] = str(ros_domain_id)
    return env


def exec_ros2(
    args: list[str],
    *,
    env: os._Environ,
    check: bool = False,
) -> subprocess.CompletedProcess[str]:
    """Run a ros2 command and return the completed process."""
    return subprocess.run(
        ["ros2", *args],
        env=env,
        check=check,
        capture_output=True,
        text=True,
        timeout=60,
    )


def list_services(ros_domain_id: int | None = None) -> subprocess.CompletedProcess[str]:
    """List ROS 2 services available in the current domain."""
    return exec_ros2(["service", "list"], env=make_env(ros_domain_id=ros_domain_id))


def list_snapd_services(
    ros_domain_id: int | None = None,
) -> subprocess.CompletedProcess[str]:
    """Call ros2_snapd list service and return the response."""
    return exec_ros2(
        [
            "service",
            "call",
            "/ros2_snapd/list",
            "ros_snapd_interfaces/srv/SnapdList",
        ],
        env=make_env(ros_domain_id=ros_domain_id),
    )


def start_snapd_service(
    service_name: str,
    *,
    ros_domain_id: int | None = None,
) -> subprocess.CompletedProcess[str]:
    """Call ros2_snapd start for a given service and return the response."""
    return exec_ros2(
        [
            "service",
            "call",
            "/ros2_snapd/start",
            "ros_snapd_interfaces/srv/SnapdStart",
            f"service: '{service_name}'",
        ],
        env=make_env(ros_domain_id=ros_domain_id),
        check=True,
    )


def stop_snapd_service(
    service_name: str,
    *,
    ros_domain_id: int | None = None,
) -> subprocess.CompletedProcess[str]:
    """Call ros2_snapd stop for a given service and return the response."""
    return exec_ros2(
        [
            "service",
            "call",
            "/ros2_snapd/stop",
            "ros_snapd_interfaces/srv/SnapdStop",
            f"service: '{service_name}'",
        ],
        env=make_env(ros_domain_id=ros_domain_id),
        check=True,
    )
