# -------------- # Models --------------

data "juju_model" "robcos_model" {
  name = var.robcos_model
}

data "juju_model" "microceph_model" {
  name = var.microceph_model
}

# -------------- # Applications --------------

module "cos_lite" {
  source     = "git::https://github.com/canonical/observability//terraform/modules/cos-lite"
  model_name = data.juju_model.robcos_model.name
  channel    = var.cos_lite.channel
  use_tls    = var.cos_lite.use_tls
}

module "robcos_overlay" {
  source                  = "../../modules/robcos_overlay"
  model                   = data.juju_model.robcos_model.name
  cos_registration_server = var.cos_registration_server
  foxglove_studio         = var.foxglove_studio
}

module "microceph" {
  source   = "../../modules/microceph"
  app_name = "microceph"
  model    = data.juju_model.microceph_model.name
  channel  = var.microceph.channel
  units    = var.microceph.units
  config   = { "enable-rgw" = "*" }
}

# -------------- # Offers --------------

resource "juju_offer" "microceph" {
  model            = data.juju_model.microceph_model.name
  application_name = module.microceph.app_name
  endpoint         = module.microceph.requires.traefik_route_rgw
}

# -------------- # Integrations --------------

# Provided by Catalogue

resource "juju_integration" "catalogue_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.catalogue
    endpoint = "catalogue"
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.catalogue
  }
}

resource "juju_integration" "catalogue_foxglove_studio" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.catalogue
    endpoint = "catalogue"
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.catalogue
  }
}

# Provided by COS registration server

resource "juju_integration" "grafana_dashboard_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.provides.grafana_dashboard
  }

  application {
    name     = module.cos_lite.app_names.grafana_agent
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_integration" "grafana_dashboard_devices_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.provides.grafana_dashboard_devices
  }

  application {
    name     = module.cos_lite.app_names.grafana
    endpoint = module.cos_lite.grafana.endpoints.grafana_dashboard
  }
}

# resource "juju_integration" "probes_cos_registration_server" {
#   model = data.juju_model.robcos_model.name

#   application {
#     name     = module.robcos_overlay.cos_registration_server.app_name
#     endpoint = module.robcos_overlay.cos_registration_server.provides.probes
#   }

#   application {
#     name     = module.cos_lite.app_names.blackbox
#     endpoint = "probes"
#   }
# }

# resource "juju_integration" "probes_devices_cos_registration_server" {
#   model = data.juju_model.robcos_model.name

#   application {
#     name     = module.robcos_overlay.cos_registration_server.app_name
#     endpoint = module.robcos_overlay.cos_registration_server.provides.probes_devices
#   }

#   application {
#     name     = module.cos_lite.app_names.blackbox
#     endpoint = "probes"
#   }
# }

# Provided by Foxglove Studio

resource "juju_integration" "grafana_dashboard_foxglove_studio" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.provides.grafana_dashboard
  }

  application {
    name     = module.cos_lite.app_names.grafana_agent
    endpoint = "grafana-dashboards-consumer"
  }
}

# resource "juju_integration" "probes_foxglove_studio" {
#   model = data.juju_model.robcos_model.name

#   application {
#     name     = module.robcos_overlay.foxglove_studio.app_name
#     endpoint = module.robcos_overlay.foxglove_studio.provides.probes
#   }

#   application {
#     name     = module.cos_lite.app_names.blackbox
#     endpoint = "probes"
#   }
# }

# Provided by Loki

resource "juju_integration" "logging_alert_devices_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.loki
    endpoint = module.cos_lite.loki.endpoints.logging #"logging"
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.logging_alerts_devices
  }
}

# Provided by Grafana Agent

resource "juju_integration" "logging_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.grafana_agent
    endpoint = "logging-provider"
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.logging
  }
}

resource "juju_integration" "tracing_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.grafana_agent
    endpoint = "tracing-provider"
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.tracing
  }
}

resource "juju_integration" "logging_foxglove_studio" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.grafana_agent
    endpoint = "logging-provider"
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.logging
  }
}

resource "juju_integration" "tracing_foxglove_studio" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.grafana_agent
    endpoint = "tracing-provider"
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.tracing
  }
}

# Provided by Prometheus

resource "juju_integration" "send_remote_write_alerts_devices_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.prometheus
    endpoint = module.cos_lite.prometheus.endpoints.receive_remote_write
    # endpoint = "receive_remote_write"
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.send_remote_write_alerts_devices
  }
}

# Provided by Traefik

resource "juju_integration" "ingress_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.traefik
    endpoint = "traefik-route"
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.ingress
  }
}

resource "juju_integration" "ingress_foxglove_studio" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.traefik
    endpoint = "traefik-route"
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.ingress
  }
}

resource "juju_integration" "ingress_microceph" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.traefik
    endpoint = "traefik-route"
  }

  application {
    offer_url = juju_offer.microceph.url
  }
}
