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
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=track/2"
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
  source             = "git::https://github.com/canonical/cos-registration-server-k8s-operator//terraform?ref=track/0"
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
  source             = "git::https://github.com/ubuntu-robotics/foxglove-k8s-operator//terraform?ref=track/0"
  units              = var.foxglove_studio.units
}
