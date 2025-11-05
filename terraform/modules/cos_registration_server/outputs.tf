output "app_name" {
  value       = juju_application.cos_registration_server.name
  description = "The name of the deployed application"
}

output "requires" {
  value = {
    catalogue                        = "catalogue"
    ingress                          = "ingress"
    logging                          = "logging"
    logging_alerts_devices           = "logging-alerts-devices"
    send_remote_write_alerts_devices = "send-remote-write-alerts-devices"
    tracing                          = "tracing"
  }
  description = "Map of the integration endpoints required by the application"
}

output "provides" {
  value = {
    auth_devices_keys         = "auth-devices-keys"
    grafana_dashboard         = "grafana-dashboard"
    grafana_dashboard_devices = "grafana-dashboard-devices"
    probes                    = "probes"
    probes_devices            = "probes-devices"
  }
  description = "Map of the integration endpoints provided by the application"
}
