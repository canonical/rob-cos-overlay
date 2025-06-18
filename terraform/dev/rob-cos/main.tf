# -------------- # Models --------------

data "juju_model" "robcos_model" {
  name = var.robcos_model
}

data "juju_model" "microceph_model" {
  name = var.microceph_model
}

# -------------- # Applications --------------

module "blackbox_exporter" {
  source   = "git::https://github.com/ubuntu-robotics/blackbox-exporter-k8s-operator//terraform?ref=feat/terraform"
  app_name = "blackbox-exporter"
  model    = data.juju_model.robcos_model.name
}

module "cos_lite" {
  # source  = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  # Use this fork until the following PRs land:
  # https://github.com/canonical/observability-stack/pull/46
  # https://github.com/canonical/observability-stack/pull/48
  source  = "git::https://github.com/ubuntu-robotics/observability-stack//terraform/cos-lite?ref=fix/cos-lite-outputs"
  channel = var.cos_lite.channel
  model   = data.juju_model.robcos_model.name
  use_tls = var.cos_lite.use_tls
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

# Provided by Blackbox Exporter

resource "juju_integration" "grafana_dashboard_blackbox_exporter" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.robcos_overlay.blackbox_exporter.app_name
    endpoint = module.robcos_overlay.blackbox_exporter.provides.grafana_dashboard
  }

  application {
    name     = module.cos_lite.app_names.grafana
    endpoint = module.cos_lite.grafana.endpoints.grafana_dashboard
  }
}

# Provided by Catalogue

resource "juju_integration" "catalogue_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.catalogue
    endpoint = module.cos_lite.catalogue.endpoints.catalogue
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
    endpoint = module.cos_lite.catalogue.endpoints.catalogue
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.catalogue
  }
}

resource "juju_integration" "catalogue_blackbox_exporter" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.catalogue
    endpoint = module.cos_lite.catalogue.endpoints.catalogue
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.requires.catalogue
  }
}

# Provided by COS registration server

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

resource "juju_integration" "probes_devices_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.provides.probes_devices
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = "probes"
  }
}

# Provided by Loki

resource "juju_integration" "logging_alert_devices_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.loki
    endpoint = module.cos_lite.loki.endpoints.logging
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.logging_alerts_devices
  }
}

# Provided by Prometheus

resource "juju_integration" "send_remote_write_alerts_devices_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.prometheus
    endpoint = module.cos_lite.prometheus.endpoints.receive_remote_write
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.send_remote_write_alerts_devices
  }
}

# Provided by Traefik

resource "juju_integration" "ingress_blackbox_exporter" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.traefik
    endpoint = module.cos_lite.traefik.endpoints.ingress
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.requires.ingress
  }
}

resource "juju_integration" "ingress_cos_registration_server" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.cos_lite.app_names.traefik
    endpoint = module.cos_lite.traefik.endpoints.traefik_route
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
    endpoint = module.cos_lite.traefik.endpoints.traefik_route
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
    endpoint = module.cos_lite.traefik.endpoints.traefik_route
  }

  application {
    offer_url = juju_offer.microceph.url
  }
}
