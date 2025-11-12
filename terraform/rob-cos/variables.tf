variable "model" {
  description = "Name of the model to deploy to (must be a K8s model)"
  type        = string
  nullable    = false
}

variable "owner" {
  description = "The owner of the model to deploy to"
  type        = string
  default     = "admin"
  nullable    = false
}

variable "blackbox_exporter" {
  type = object({
    channel  = optional(string, "1/stable")
    revision = optional(number)
  })
  default     = {}
  description = <<-EOT
  The blackbox-exporter variables.
  Please refer to the module for more information.
  EOT
}

variable "cos_lite" {
  type = object({
    channel      = optional(string, "1/stable")
    internal_tls = optional(bool, false)
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
