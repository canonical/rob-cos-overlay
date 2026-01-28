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
