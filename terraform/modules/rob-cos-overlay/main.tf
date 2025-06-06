# -------------- # Model --------------

data "juju_model" "model" {
  name = var.model
}

# -------------- # Applications --------------

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
