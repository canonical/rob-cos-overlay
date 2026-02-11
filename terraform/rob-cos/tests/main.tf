data "juju_model" "model" {
  name  = "testing"
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

module "rob_cos" {
  model  = data.juju_model.model.name
  source = "./.."
}
