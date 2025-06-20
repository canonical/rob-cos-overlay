# -------------- # Controllers --------------

provider "juju" {
  alias                = "robcos"
  controller_addresses = var.robcos_controller.addresses
  username             = var.robcos_controller.username
  password             = var.robcos_controller.password
  ca_certificate       = var.robcos_controller.ca_certificate_path != null ? file(var.robcos_controller.ca_certificate_path) : null
}

provider "juju" {
  alias                = "microceph"
  controller_addresses = var.microceph_controller.addresses
  username             = var.microceph_controller.username
  password             = var.microceph_controller.password
  ca_certificate       = var.microceph_controller.ca_certificate_path != null ? file(var.microceph_controller.ca_certificate_path) : null
}

# -------------- # Models --------------

data "juju_model" "robcos_model" {
  name     = var.robcos_model
  provider = juju.robcos
}

data "juju_model" "microceph_model" {
  name     = var.microceph_model
  provider = juju.microceph
}

# -------------- # Applications --------------

module "rob_cos" {
  source   = "../rob-cos"
  model    = data.juju_model.robcos_model.name
  cos_lite = var.cos_lite

  providers = {
    juju = juju.robcos
  }
}

module "microceph" {
  source   = "../microceph"
  app_name = "microceph"
  model    = data.juju_model.microceph_model.name
  channel  = var.microceph.channel
  units    = var.microceph.units
  config   = { "enable-rgw" = "*" }

  providers = {
    juju = juju.microceph
  }
}

# -------------- # Offers --------------

resource "juju_offer" "microceph" {
  model            = data.juju_model.microceph_model.name
  application_name = module.microceph.app_name
  endpoint         = module.microceph.requires.traefik_route_rgw

  provider = juju.microceph
}

# -------------- # Integrations --------------

# Provided by Traefik

resource "juju_integration" "ingress_microceph" {
  model = data.juju_model.robcos_model.name

  application {
    name     = module.rob_cos.components.traefik.app_name
    endpoint = module.rob_cos.components.traefik.endpoints.traefik_route
  }

  application {
    offer_url = juju_offer.microceph.url
  }

  provider = juju.robcos
}
