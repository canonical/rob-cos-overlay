# -------------- # Models --------------

data "juju_model" "model" {
  name = var.model
}

# -------------- # Applications --------------

module "blackbox_exporter" {
  source   = "git::https://github.com/ubuntu-robotics/blackbox-exporter-k8s-operator//terraform?ref=feat/terraform"
  app_name = "blackbox-exporter"
  model    = data.juju_model.model.name
  channel  = var.blackbox_exporter.channel
  revision = var.blackbox_exporter.revision
}

module "cos_lite" {
  source  = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  channel = var.cos_lite.channel
  model   = data.juju_model.model.name
  use_tls = var.cos_lite.use_tls
}

module "cos_registration_server" {
  source   = "git::https://github.com/canonical/cos-registration-server-k8s-operator//terraform"
  app_name = "cos-registration-server"
  model    = data.juju_model.model.name
  channel  = var.cos_registration_server.channel
  revision = var.cos_registration_server.revision
}

module "foxglove_studio" {
  source   = "git::https://github.com/ubuntu-robotics/foxglove-k8s-operator//terraform"
  app_name = "foxglove-studio"
  model    = data.juju_model.model.name
  channel  = var.foxglove_studio.channel
  revision = var.foxglove_studio.revision
}

# -------------- # Offers --------------

# -------------- # Integrations --------------

# Provided by Blackbox Exporter

resource "juju_integration" "grafana_dashboard_blackbox_exporter" {
  model = data.juju_model.model.name

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.provides.grafana_dashboard
  }

  application {
    name     = module.cos_lite.components.grafana.app_name
    endpoint = module.cos_lite.components.grafana.endpoints.grafana_dashboard
  }
}

# Provided by Catalogue

resource "juju_integration" "catalogue_cos_registration_server" {
  model = data.juju_model.model.name

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
  model = data.juju_model.model.name

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
  model = data.juju_model.model.name

  application {
    name     = module.cos_lite.components.catalogue.app_name
    endpoint = module.cos_lite.components.catalogue.endpoints.catalogue
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.requires.catalogue
  }
}

# Provided by COS registration server

resource "juju_integration" "grafana_dashboard_devices_cos_registration_server" {
  model = data.juju_model.model.name

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
  model = data.juju_model.model.name

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
  model = data.juju_model.model.name

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
  model = data.juju_model.model.name

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
  model = data.juju_model.model.name

  application {
    name     = module.cos_lite.components.traefik.app_name
    endpoint = module.cos_lite.components.traefik.endpoints.ingress
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.requires.ingress
  }
}

resource "juju_integration" "ingress_cos_registration_server" {
  model = data.juju_model.model.name

  application {
    name     = module.cos_lite.components.traefik.app_name
    endpoint = module.cos_lite.components.traefik.endpoints.traefik_route
  }

  application {
    name     = module.cos_registration_server.app_name
    endpoint = module.cos_registration_server.requires.ingress
  }
}

resource "juju_integration" "ingress_foxglove_studio" {
  model = data.juju_model.model.name

  application {
    name     = module.cos_lite.components.traefik.app_name
    endpoint = module.cos_lite.components.traefik.endpoints.traefik_route
  }

  application {
    name     = module.foxglove_studio.app_name
    endpoint = module.foxglove_studio.requires.ingress
  }
}
