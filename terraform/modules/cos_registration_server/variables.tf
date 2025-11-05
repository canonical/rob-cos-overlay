variable "app_name" {
  description = "Name to give the deployed application"
  type        = string
  nullable    = false
  default     = "cos-registration-server"
}

variable "channel" {
  description = "Channel that the charm is deployed from"
  type        = string
  nullable    = false
  default     = "latest/edge"
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
  nullable    = false
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

variable "resources" {
  description = "Resources used by the charm"
  type        = map(string)
  default = {
    cos-registration-server-image : "ghcr.io/canonical/cos-registration-server:dev"
  }
}

variable "storage" {
  description = "Map of storage used by the application. Defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}
