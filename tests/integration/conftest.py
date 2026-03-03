#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Conftest file for integration tests."""

import os

import pytest
from terraform import TfDirManager
from juju import temp_named_model


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
