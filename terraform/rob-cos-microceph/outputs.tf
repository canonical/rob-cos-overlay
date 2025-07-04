output "app_names" {
  value = merge(
    merge(
      {
        microceph = module.microceph.app_name,
      }
    ),
    module.rob_cos.app_names
  )
  description = "The names of the deployed applications"
}

output "components" {
  value = merge(
    merge(
      {
        microceph = module.microceph
      }
    ),
    module.rob_cos.components,
  )
  description = "Outputs of the deployed applications"
}
