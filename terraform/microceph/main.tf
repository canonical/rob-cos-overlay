# -------------- # Models --------------

data "juju_model" "model" {
  uuid = var.model_uuid
}

# -------------- # Application --------------

resource "juju_application" "microceph" {
  name       = var.app_name
  model_uuid = var.model_uuid
  # We always need this variable to be true in order
  # to be able to apply resources limits.
  trust = true
  charm {
    name     = "microceph"
    channel  = var.channel
    revision = var.revision
  }
  units  = var.units
  config = var.config
}
