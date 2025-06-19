# -------------- # Models --------------

data "juju_model" "robcos_model" {
  name = var.robcos_model
}

data "juju_model" "microceph_model" {
  name = var.microceph_model
}

# -------------- # Applications --------------

module "rob_cos" {
  source = "../rob-cos"
  model  = data.juju_model.robcos_model.name
}

module "microceph" {
  source   = "../microceph"
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
}
