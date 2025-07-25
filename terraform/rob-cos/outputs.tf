output "app_names" {
  value = merge(
    {
      blackbox_exporter      = module.blackbox_exporter.app_name,
      cos_registratio_server = module.cos_registration_server.app_name,
      foxglove_studio        = module.foxglove_studio.app_name,
      #cos_lite               = module.cos_lite.app_names,
    }
  )
  description = "The names of the deployed applications"
}

output "components" {
  value = merge(
    merge(
      {
        blackbox_exporter       = module.blackbox_exporter,
        cos_registration_server = module.cos_registration_server,
        foxglove_studio         = module.foxglove_studio,
      }
    ),
    module.cos_lite.components,
  )
  description = "Outputs of the deployed applications"
}
