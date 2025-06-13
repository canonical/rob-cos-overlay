variable "robcos_model" {
  description = "Model name (must be a k8s model)"
  type        = string
}

variable "microceph_model" {
  description = "Model name (must be a machine model)"
  type        = string
}

variable "cos_lite" {
  type = object({
    channel = optional(string, "latest/edge")
    use_tls = optional(bool, false)
  })
  default     = {}
  description = <<-EOT
  The cos-lite variables.
  Please refer to the module for more information.
  EOT
}

variable "cos_registration_server" {
  type = object({
    channel  = optional(string, "latest/edge")
    revision = optional(number, null)
  })
  default     = {}
  description = <<-EOT
  The cos-registration-server variables.
  Please refer to the module for more information.
  EOT
}

variable "foxglove_studio" {
  type = object({
    channel  = optional(string, "latest/edge")
    revision = optional(number, null)
  })
  default     = {}
  description = <<-EOT
  The foxglove-studio variables.
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
