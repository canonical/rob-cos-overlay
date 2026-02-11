variable "model" {
  type    = string
  default = "testing"
}

data "juju_model" "model" {

  name  = var.model
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
  model  = var.model
  source = "./rob-cos-overlay/terraform/rob-cos"
}

