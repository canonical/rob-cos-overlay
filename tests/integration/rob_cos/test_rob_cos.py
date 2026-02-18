from pathlib import Path

from helpers import (
    blackbox_catalogue_ingress_fix,
    catalogue_apps_are_reachable,
    wait_for_active_idle_without_error,
)

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
