output "app_names" {
  value = merge(
    {
      blackbox_exporter      = module.blackbox_exporter.app_name,
      cos_registratio_server = module.robcos_overlay.cos_registration_server.app_name,
      foxglove_studio        = module.robcos_overlay.foxglove_studio.app_name,
    }
  )
  description = "The names of the deployed applications"
}

output "blackbox_exporter" {
  description = "Outputs from the Blackbox-exporter module"
  value       = module.blackbox_exporter
}

output "cos_lite" {
  description = "Outputs from the COS lite module"
  value       = module.cos_lite
}

output "robcos_overlay" {
  description = "Outputs from the robcos-overlay module"
  value       = module.robcos_overlay
}

output "microceph" {
  description = "Outputs from the microceph module"
  value       = module.microceph
}
