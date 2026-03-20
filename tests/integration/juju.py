"""Juju/Jubilant integration helpers."""

import contextlib
import json
import logging
import ssl
import subprocess
from pathlib import Path
from typing import Generator, List, Optional
from urllib.request import urlopen

import jubilant
from collections.abc import Mapping

logger = logging.getLogger(__name__)


# We must used a named model since
# the Ubuntu Core images built for
# the robots have hardcoded values
@contextlib.contextmanager
def temp_named_model(
    name: str,
    keep: bool = False,
    controller: str | None = None,
    cloud: str | None = None,
    config: Mapping[str, jubilant._juju.ConfigValue] | None = None,
    credential: str | None = None,
) -> Generator[jubilant.Juju, None, None]:
    """Create and yield a temporary Juju model."""
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
    """Wait for models to settle without errors."""
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
    """Return an SSL context from the external CA, if available."""
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
    """Recreate blackbox exporter relation for catalogue ingress."""
    # FIXME: https://github.com/canonical/blackbox-exporter-k8s-operator/issues/74
    juju.remove_relation("blackbox-exporter:catalogue", "catalogue:catalogue")
    wait_for_active_idle_without_error([juju])
    juju.integrate("blackbox-exporter:catalogue", "catalogue:catalogue")
    wait_for_active_idle_without_error([juju])


def catalogue_apps_are_reachable(
    juju: jubilant.Juju, tls_context: Optional[ssl.SSLContext] = None
):
    """Assert catalogue apps are reachable from the catalogue unit."""
    stdout = juju.ssh("catalogue/0", "cat /web/config.json", container="catalogue")
    cat_conf = json.loads(stdout)
    apps = {app["name"]: app["url"] for app in cat_conf["apps"]}
    for app, url in apps.items():
        if not url:
            continue
        response = urlopen(url, data=None, timeout=2.0, context=tls_context)
        assert response.code == 200, f"{app} was not reachable"


def trigger_update_status(juju: jubilant.Juju, unit: str) -> None:
    """Trigger an update-status hook using juju ssh and juju-exec."""
    model = juju.model
    if not model:
        raise AssertionError("Juju model not set")
    unit_sanitized = f"unit-{unit.replace('/', '-')}"
    dispatch_path = f"/var/lib/juju/agents/{unit_sanitized}/charm/dispatch"
    cmd = (
        f"/usr/bin/juju-exec -u {unit} "
        f"JUJU_DISPATCH_PATH=hooks/update-status "
        f"JUJU_MODEL_NAME={model} "
        f"JUJU_UNIT_NAME={unit} "
        f"{dispatch_path}"
    )
    juju._cli("ssh", "-m", model, unit, cmd)


def show_unit(juju: jubilant.Juju, unit: str) -> dict:
    """Return show-unit data for a unit."""
    output = juju._cli("show-unit", unit, "--format", "json")
    if isinstance(output, (tuple, list)):
        output = output[0]
    data = json.loads(output)
    if isinstance(data, dict) and unit in data:
        return data[unit]
    return data


def relation_application_data(
    juju: jubilant.Juju,
    unit: str,
    endpoint: str,
    related_unit: str,
    related_endpoint: str,
) -> list[dict]:
    """Return relation application-data entries for a unit relation."""
    unit_data = show_unit(juju, unit)
    data_items: list[dict] = []
    for rel in unit_data.get("relation-info", []):
        if rel.get("endpoint") != endpoint:
            continue
        if rel.get("related-endpoint") != related_endpoint:
            continue
        related_units = rel.get("related-units", {})
        if not isinstance(related_units, dict) or related_unit not in related_units:
            continue
        app_data = rel.get("application-data")
        if isinstance(app_data, dict) and app_data:
            data_items.append(app_data)
        related_app = rel.get("related-application")
        if isinstance(related_app, dict):
            related_app_data = related_app.get("application-data")
            if isinstance(related_app_data, dict) and related_app_data:
                data_items.append(related_app_data)
    return data_items


def find_application_data(
    juju: jubilant.Juju,
    unit: str,
    endpoint: str,
    related_unit: str,
    related_endpoint: str,
    key: str,
) -> dict:
    """Return the first application-data dict that includes key."""
    for app_data in relation_application_data(
        juju, unit, endpoint, related_unit, related_endpoint
    ):
        if key in app_data:
            return app_data
    raise AssertionError(f"Expected {unit} relation application-data to include {key}")
