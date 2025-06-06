output "app_names" {
  value = merge(
    {
      cos_registratio_server = module.cos_registration_server.app_name,
      foxglove_studio        = module.foxglove_studio.app_name,
    }
  )
  description = "The names of the deployed applications"
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
