# -------------- # Models --------------

data "juju_model" "model" {
  name  = var.model
  owner = var.model_owner
}

# -------------- # Applications --------------

module "blackbox_exporter" {
  app_name    = var.blackbox_exporter.app_name
  channel     = var.blackbox_exporter.channel
  config      = var.blackbox_exporter.config
  constraints = var.blackbox_exporter.constraints
  model_uuid  = data.juju_model.model.uuid
  revision    = var.blackbox_exporter.revision
  source      = "git::https://github.com/ubuntu-robotics/blackbox-exporter-k8s-operator//terraform?ref=feat/terraform"
  units       = var.blackbox_exporter.units
}

module "cos_lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  channel      = var.cos_lite.channel
  model_uuid   = data.juju_model.model.uuid
  internal_tls = var.cos_lite.internal_tls
}

module "cos_registration_server" {
  app_name           = var.cos_registration_server.app_name
  channel            = var.cos_registration_server.channel
  config             = var.cos_registration_server.config
  constraints        = var.cos_registration_server.constraints
  model_uuid         = data.juju_model.model.uuid
  storage_directives = var.cos_registration_server.storage_directives
  revision           = var.cos_registration_server.revision
  source             = "git::https://github.com/canonical/cos-registration-server-k8s-operator//terraform"
  units              = var.cos_registration_server.units
}

module "foxglove_studio" {
  app_name           = var.foxglove_studio.app_name
  channel            = var.foxglove_studio.channel
  config             = var.foxglove_studio.config
  constraints        = var.foxglove_studio.constraints
  model_uuid         = data.juju_model.model.uuid
  storage_directives = var.foxglove_studio.storage_directives
  revision           = var.foxglove_studio.revision
  source             = "git::https://github.com/ubuntu-robotics/foxglove-k8s-operator//terraform"
  units              = var.foxglove_studio.units
}

# -------------- # Offers --------------

# -------------- # Integrations --------------

# Provided by Blackbox Exporter

resource "juju_integration" "grafana_dashboard_blackbox_exporter" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.endpoints.grafana_dashboard
  }

  application {
    name     = module.cos_lite.components.grafana.app_name
    endpoint = module.cos_lite.components.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "self_metrics_endpoint_blackbox_exporter" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.cos_lite.components.prometheus.app_name
    endpoint = module.cos_lite.components.prometheus.endpoints.metrics_endpoint
  }
}

# Provided by Catalogue

resource "juju_integration" "catalogue_cos_registration_server" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.catalogue.app_name
    endpoint = module.cos_lite.components.catalogue.endpoints.catalogue
  }

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.requires.catalogue
  }
}

resource "juju_integration" "catalogue_foxglove_studio" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.catalogue.app_name
    endpoint = module.cos_lite.components.catalogue.endpoints.catalogue
  }

  application {
    name     = module.foxglove_studio.app_name
    endpoint = module.foxglove_studio.requires.catalogue
  }
}

resource "juju_integration" "catalogue_blackbox_exporter" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.catalogue.app_name
    endpoint = module.cos_lite.components.catalogue.endpoints.catalogue
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.endpoints.catalogue
  }
}

# Provided by COS registration server

resource "juju_integration" "grafana_dashboard_devices_cos_registration_server" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.provides.grafana_dashboard_devices
  }

  application {
    name     = module.cos_lite.components.grafana.app_name
    endpoint = module.cos_lite.components.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "probes_devices_cos_registration_server" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.provides.probes_devices
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = "probes"
  }
}

# Provided by Loki

resource "juju_integration" "logging_alert_devices_cos_registration_server" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.loki.app_name
    endpoint = module.cos_lite.components.loki.endpoints.logging
  }

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.requires.logging_alerts_devices
  }
}

# Provided by Prometheus

resource "juju_integration" "send_remote_write_alerts_devices_cos_registration_server" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.prometheus.app_name
    endpoint = module.cos_lite.components.prometheus.endpoints.receive_remote_write
  }

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.requires.send_remote_write_alerts_devices
  }
}

# Provided by Traefik

resource "juju_integration" "ingress_blackbox_exporter" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.traefik.app_name
    endpoint = module.cos_lite.components.traefik.endpoints.ingress
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.endpoints.ingress
  }
}

resource "juju_integration" "ingress_cos_registration_server" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.traefik.app_name
    endpoint = module.cos_lite.components.traefik.endpoints.ingress
  }

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.requires.ingress
  }
}

resource "juju_integration" "ingress_foxglove_studio" {
  model_uuid = data.juju_model.model.uuid

  application {
    name     = module.cos_lite.components.traefik.app_name
    endpoint = module.cos_lite.components.traefik.endpoints.ingress
  }

  application {
    name     = module.foxglove_studio.app_name
    endpoint = module.foxglove_studio.requires.ingress
  }
}
