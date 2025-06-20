variable "robcos_model" {
  description = "Name of the K8s model to deploy rob-cos to"
  type        = string
}

variable "microceph_model" {
  description = "Name of the machine model to deploy microceph to"
  type        = string
}

variable "robcos_controller" {
  type = object({
    addresses           = optional(string)
    username            = optional(string)
    password            = optional(string)
    ca_certificate_path = optional(string)
  })
  default     = {}
  description = <<-EOT
  The Juju controller credentials for the controller managing the K8s model
  where rob-cos is to be deployed
  EOT
}

variable "microceph_controller" {
  type = object({
    addresses           = optional(string)
    username            = optional(string)
    password            = optional(string)
    ca_certificate_path = optional(string)
  })
  default     = {}
  description = <<-EOT
  The Juju controller credentials for the controller managing the machine model
  where microceph is to be deployed
  EOT
}

variable "cos_lite" {
  type = object({
    channel = optional(string, "1/stable")
    use_tls = optional(bool, false)
  })
  default     = {}
  description = <<-EOT
  The cos-lite variables.
  Please refer to the module for more information.
  EOT
}

variable "microceph" {
  type = object({
    channel  = optional(string, "squid/stable")
    revision = optional(number, null)
    units    = optional(number, 3)
  })
  default     = {}
  description = <<-EOT
  The microceph variables.
  Please refer to the module for more information.
  EOT
}

variable "rob_cos" {
  type = object({
    channel = optional(string, "latest/edge")
  })
  default     = {}
  description = <<-EOT
  The rob-cos variables.
  Please refer to the module for more information.
  EOT
}
