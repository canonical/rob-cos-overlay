run "basic_deploy" {
  command = apply

  # This corresponds to the apps deployed by rob_cos_microceph.
  # cos_lite tf module doesn't output app_names.
  assert {
    condition     = length(module.rob_cos_microceph.app_names) == 4
    error_message = "app_names output should not be empty"
  }

  assert {
    condition     = contains(keys(module.rob_cos_microceph.app_names), "microceph")
    error_message = "app_names is missing microceph"
  }

  assert {
    condition     = contains(keys(module.rob_cos_microceph.app_names), "blackbox_exporter")
    error_message = "app_names is missing blackbox_exporter"
  }

  assert {
    condition     = contains(keys(module.rob_cos_microceph.app_names), "cos_registration_server")
    error_message = "app_names is missing cos_registration_server"
  }

  assert {
    condition     = contains(keys(module.rob_cos_microceph.app_names), "foxglove_studio")
    error_message = "app_names is missing foxglove_studio"
  }

  assert {
    condition     = module.rob_cos_microceph.components.microceph.app_name != ""
    error_message = "microceph app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.blackbox_exporter.app_name != ""
    error_message = "blackbox_exporter app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.cos_registration_server.app_name != ""
    error_message = "cos_registration_server app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.foxglove_studio.app_name != ""
    error_message = "foxglove_studio app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.traefik.app_name != ""
    error_message = "traefik app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.catalogue.app_name != ""
    error_message = "catalogue app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.grafana.app_name != ""
    error_message = "grafana app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.loki.app_name != ""
    error_message = "loki app_name should be set"
  }

  assert {
    condition     = module.rob_cos_microceph.components.prometheus.app_name != ""
    error_message = "prometheus app_name should be set"
  }
}
