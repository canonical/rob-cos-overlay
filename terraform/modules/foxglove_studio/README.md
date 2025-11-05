# Terraform module for `foxglove-studio-k8s`

This is a Terraform module facilitating the deployment of the `foxglove-studio-k8s` charm,
using the [Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

> [!IMPORTANT]
> This module requires a Juju K8s model to be available.
> Refer to the [usage section](#usage) below for more details.

## Usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

Example usage:

```hcl
data "juju_model" "model" {
  name = var.model_name
}

module "foxglove_studio" {
  source     = "./terraform/modules/foxglove_studio"
  model_uuid = data.juju_model.model.uuid
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| juju | ~> 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| juju | ~> 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [juju_application.foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| model_uuid | UUID of the model to deploy to (must be a K8s model) | `string` | n/a | yes |
| app\_name | Name to give the deployed application | `string` | `"foxglove-studio"` | no |
| channel | Channel that the charm is deployed from | `string` | `"latest/edge"` | no |
| config | Map of the charm configuration options | `map(string)` | `{}` | no |
| constraints | String listing constraints for the application | `string` | `"arch=amd64"` | no |
| resources | Resources used by the charm | `map(string)` | ```{ "foxglove-studio-image": "ghcr.io/ubuntu-robotics/foxglove-studio:dev" }``` | no |
| revision | Revision number of the charm | `number` | `null` | no |
| storage | Map of storage used by the application. Defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| units | Unit count/scale | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_name | The name of the deployed application |
| provides | Map of the integration endpoints provided by the application |
| requires | Map of the integration endpoints required by the application |
<!-- END_TF_DOCS -->
