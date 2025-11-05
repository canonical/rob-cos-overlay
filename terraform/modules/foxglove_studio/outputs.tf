output "app_name" {
  value       = juju_application.foxglove_studio.name
  description = "The name of the deployed application"
}

output "requires" {
  value = {
    catalogue = "catalogue"
    ingress   = "ingress"
    logging   = "logging"
    tracing   = "tracing"
  }
  description = "Map of the integration endpoints required by the application"
}

output "provides" {
  value = {
    grafana_dashboard = "grafana-dashboard"
    probes            = "probes"
  }
  description = "Map of the integration endpoints provided by the application"
}
