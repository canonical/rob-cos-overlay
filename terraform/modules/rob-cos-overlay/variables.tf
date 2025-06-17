variable "model" {
  description = "Name of the model to deploy to (must be a K8s model)"
  type        = string
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
