# -------------- # Variables --------------

variable "use_cos" {
  description = <<-EOT
  Specify whether this deployment is observed by COS or not.
  Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "grafana_agent" {
  type = object({
    channel  = optional(string, "latest/edge")
    revision = optional(number, null)
  })
  default     = {}
  description = <<-EOT
  The grafana-agent variables.
  Please refer to the module for more information.
  EOT
}

# -------------- # Models --------------

data "juju_model" "model" {
  name = var.robcos_model
}

# -------------- # Applications --------------

module "grafana_agent" {
  source   = "git::https://github.com/canonical/grafana-agent-k8s-operator//terraform"
  app_name = "grafana-agent"
  model    = juju_model.model.name
  channel  = var.grafana_agent.channel
  revision = var.grafana_agent.revision
  count    = var.use_cos ? 1 : 0
}

# -------------- # Offers --------------


# -------------- # Integrations --------------

# Provided by COS registration server

resource "juju_integration" "grafana_dashboard_cos_registration_server" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.provides.grafana_dashboard
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.grafana_dashboards_consumer
  }
}

# resource "juju_integration" "probes_cos_registration_server" {
#   model = data.juju_model.model.name

#   application {
#     name     = module.robcos_overlay.cos_registration_server.app_name
#     endpoint = module.robcos_overlay.cos_registration_server.provides.probes
#   }

#   application {
#     name     = module.blackbox_exporter.app_name
#     endpoint = "probes"
#   }
# }

# Provided by Foxglove Studio

resource "juju_integration" "grafana_dashboard_foxglove_studio" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.provides.grafana_dashboard
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.grafana_dashboards_consumer
  }
}

# resource "juju_integration" "probes_foxglove_studio" {
#   model = data.juju_model.model.name

#   application {
#     name     = module.robcos_overlay.foxglove_studio.app_name
#     endpoint = module.robcos_overlay.foxglove_studio.provides.probes
#   }

#   application {
#     name     = module.blackbox_exporter.app_name
#     endpoint = "probes"
#   }
# }

# Provided by Grafana Agent

resource "juju_integration" "logging_cos_registration_server" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging-provider
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.logging
  }
}

resource "juju_integration" "tracing_cos_registration_server" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.tracing-provider
  }

  application {
    name     = module.robcos_overlay.cos_registration_server.app_name
    endpoint = module.robcos_overlay.cos_registration_server.requires.tracing
  }
}

resource "juju_integration" "logging_foxglove_studio" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging-provider
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.logging
  }
}

resource "juju_integration" "tracing_foxglove_studio" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.tracing-provider
  }

  application {
    name     = module.robcos_overlay.foxglove_studio.app_name
    endpoint = module.robcos_overlay.foxglove_studio.requires.tracing
  }
}

resource "juju_integration" "logging_blackbox_exporter" {
  model = data.juju_model.model.name
  count = var.use_cos ? 1 : 0

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging-provider
  }

  application {
    name     = module.blackbox_exporter.app_name
    endpoint = module.blackbox_exporter.requires.logging
  }
}
