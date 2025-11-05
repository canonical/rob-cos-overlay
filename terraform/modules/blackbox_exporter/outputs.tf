output "app_name" {
  value       = juju_application.blackbox_exporter.name
  description = "The name of the deployed application"
}

output "endpoints" {
  value = {
    # Requires
    catalogue = "catalogue"
    ingress   = "ingress"
    logging   = "logging"
    probes    = "probes"
    # Provides
    self_metrics_endpoint = "self-metrics-endpoint"
    grafana_dashboard     = "grafana-dashboard"
  }
}
