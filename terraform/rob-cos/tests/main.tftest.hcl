run "basic_deploy" {
  command = apply

  # This corresponds to the apps deployed by rob_cos.
  # cos_lite tf module doesn't output app_names.
  assert {
    condition     = length(module.rob_cos.app_names) == 3
    error_message = "app_names output should not be empty"
  }

  assert {
    condition     = contains(keys(module.rob_cos.app_names), "blackbox_exporter")
    error_message = "app_names is missing blackbox_exporter"
  }

  assert {
    condition     = contains(keys(module.rob_cos.app_names), "cos_registration_server")
    error_message = "app_names is missing cos_registration_server"
  }

  assert {
    condition     = contains(keys(module.rob_cos.app_names), "foxglove_studio")
    error_message = "app_names is missing foxglove_studio"
  }

  assert {
    condition     = module.rob_cos.components.blackbox_exporter.app_name != ""
    error_message = "blackbox_exporter app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.cos_registration_server.app_name != ""
    error_message = "cos_registration_server app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.foxglove_studio.app_name != ""
    error_message = "foxglove_studio app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.catalogue.app_name != ""
    error_message = "cos-lite catalogue app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.alertmanager.app_name != ""
    error_message = "cos-lite alertmanager app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.grafana.app_name != ""
    error_message = "cos-lite grafana app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.loki.app_name != ""
    error_message = "cos-lite loki app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.prometheus.app_name != ""
    error_message = "cos-lite prometheus app_name should be set"
  }

  assert {
    condition     = module.rob_cos.components.traefik.app_name != ""
    error_message = "cos-lite traefik app_name should be set"
  }

  # We do not deploy ssc by default
  assert {
    condition     = contains(keys(module.rob_cos.app_names), "ssc") == false
    error_message = "cos-lite ssc app_name should be set"
  }
}
