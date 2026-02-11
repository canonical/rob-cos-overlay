data "juju_model" "robcos_model" {
  name  = "testing"
  owner = "admin"
}

data "juju_model" "microceph_model" {
  name  = "testing-lxd"
  owner = "admin"
}

terraform {
  required_providers {
    juju = {
      version = "~> 1.0"
      source  = "juju/juju"
    }
  }
}

provider "juju" {}

module "rob_cos_microceph" {
  source               = "./.."
  robcos_model_uuid    = data.juju_model.robcos_model.uuid
  microceph_model_uuid = data.juju_model.microceph_model.uuid
}
