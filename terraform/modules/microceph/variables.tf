variable "app_name" {
  description = "Name to give the deployed application"
  type        = string
  default     = "microceph"
}

variable "channel" {
  description = "Channel that the charm is deployed from"
  type        = string
  default     = "squid/stable"
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

variable "model" {
  description = "Name of the model to deploy to (must be a machine model)"
  type        = string
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
