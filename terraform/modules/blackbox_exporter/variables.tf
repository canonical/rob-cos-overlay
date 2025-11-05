variable "app_name" {
  description = "Name to give the deployed application"
  type        = string
  default     = "blackbox-exporter"
}

variable "channel" {
  description = "Channel that the charm is deployed from"
  type        = string
  default     = "1/stable"
}

variable "config" {
  description = "Map of the charm configuration options"
  type        = map(string)
  default     = {}
}

# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose
variable "constraints" {
  description = "String listing constraints for the application"
  type        = string
  default     = "arch=amd64"
}

variable "model_uuid" {
  description = "UUID of the model to deploy to (must be a K8s model)"
  type        = string
}

variable "resources" {
  description = "Resources used by the charm"
  type        = map(string)
  default = {
    blackbox-exporter-image : "ubuntu/blackbox-exporter:0.26-24.04"
  }
}

variable "revision" {
  description = "Revision number of the charm"
  type        = number
  nullable    = true
  default     = null
}

variable "units" {
  description = "Unit count/scale"
  type        = number
  default     = 1
}
