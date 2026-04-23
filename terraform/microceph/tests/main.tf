data "juju_model" "model" {
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

module "microceph" {
  model  = data.juju_model.model.name
  source = "./.."
}
