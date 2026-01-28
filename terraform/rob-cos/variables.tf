variable "model" {
  description = "Name of the model to deploy to (must be a K8s model)"
  type        = string
  nullable    = false
}

variable "model_owner" {
  description = "The owner of the model to deploy to"
  type        = string
  default     = "admin"
  nullable    = false
}

variable "blackbox_exporter" {
  type = object({
    app_name           = optional(string, "blackbox-exporter")
    channel            = optional(string, "1/stable")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    units              = optional(number, 1)
  })
  default     = {}
  description = <<-EOT
  Application configuration for Blackbox Exporter.
  For more details: https://github.com/ubuntu-robotics/blackbox-exporter-k8s-operator/tree/feat/terraform/terraform
  EOT
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

variable "cos_registration_server" {
  type = object({
    app_name           = optional(string, "cos-registration-server")
    channel            = optional(string, "0/stable")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = <<-EOT
  Application configuration for COS Registration Server.
  For more details: https://github.com/ubuntu-robotics/cos-registration-server-k8s-operator/tree/main/terraform
  EOT
}

variable "foxglove_studio" {
  type = object({
    app_name           = optional(string, "foxglove-studio")
    channel            = optional(string, "0/stable")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = <<-EOT
  Application configuration for Foxglove Studio.
  For more details: https://github.com/ubuntu-robotics/foxglove-k8s-operator/tree/main/terraform
  EOT
}
