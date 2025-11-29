variable "robcos_model_uuid" {
  description = "UUID of the K8s model to deploy rob-cos to"
  type        = string
  nullable    = false
}

variable "microceph_model_uuid" {
  description = "UUID of the machine model to deploy MicroCeph to"
  type        = string
  nullable    = false
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
  sensitive   = true
  ephemeral   = true
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
  where MicroCeph is to be deployed
  EOT
  sensitive   = true
  ephemeral   = true
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
  The MicroCeph variables.
  Please refer to the module for more information.
  EOT
}

variable "rob_cos" {
  type = object({
    # channel = optional(string, "latest/edge")
  })
  default     = {}
  description = <<-EOT
  The rob-cos variables.
  Please refer to the module for more information.
  EOT
}
