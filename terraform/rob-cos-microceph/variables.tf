variable "robcos_model" {
  description = "Name of the K8s model to deploy rob-cos to"
  type        = string
}

variable "microceph_model" {
  description = "Name of the machine model to deploy microceph to"
  type        = string
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
