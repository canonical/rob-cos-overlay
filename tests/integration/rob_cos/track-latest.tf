variable "model" {
  type    = string
  default = "testing"
}

variable "cos_lite" {
  type = object({
    channel      = optional(string, "1/stable")
    internal_tls = optional(bool, false)
  })
  default     = {}
  description = <<-EOT
  Applications configurations for COS Lite.
  For more details: https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite
  EOT
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
  model    = var.model
  source   = "./rob-cos-overlay/terraform/rob-cos"
  cos_lite = var.cos_lite
}
