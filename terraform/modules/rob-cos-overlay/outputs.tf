output "app_names" {
  value = merge(
    {
      cos_registratio_server = module.cos_registration_server.app_name,
      foxglove_studio        = module.foxglove_studio.app_name,
    }
  )
  description = "The names of the deployed applications"
}

output "cos_registration_server" {
  description = "Outputs from the COS registration server module"
  value       = module.cos_registration_server
}

output "foxglove_studio" {
  description = "Outputs from the Foxglove Studio module"
  value       = module.foxglove_studio
}
