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
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=22bdedde6e106774d2c6325aa912572db5c76ae0"
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

module "postgresql" {
  app_name           = var.postgresql.app_name
  base               = var.postgresql.base
  channel            = var.postgresql.channel
  config             = var.postgresql.config
  constraints        = var.postgresql.constraints
  model_uuid         = data.juju_model.model.uuid
  resources          = var.postgresql.resources
  revision           = var.postgresql.revision
  source             = "git::https://github.com/canonical/postgresql-k8s-operator//terraform?ref=986f614b9e437cb69f8ad0d51a1d03d0225033a3"
  storage_directives = var.postgresql.storage_directives
  units              = var.postgresql.units
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
