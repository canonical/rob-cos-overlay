# Terraform module for `microceph`

This is a Terraform module facilitating the deployment of the `microceph` charm,
using the [Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

> Note: This module temporarily lives here until the microceph charm provides its own.

## Requirements

This module requires a Juju machine model to be available.
Refer to the [usage section](#usage) below for more details.

## Usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run:

```bash
terraform apply -var="model=<MODEL_NAME>"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| juju | ~> 0.19.0 |

## Providers

| Name | Version |
|------|---------|
| juju | ~> 0.19.0 |

## Resources

| Name | Type |
|------|------|
| [juju_application.microceph](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_model.model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| model | Model name (must be a machine model) | `string` | n/a | yes |
| app\_name | Application name | `string` | `"microceph"` | no |
| channel | Charm channel | `string` | `"squid/stable"` | no |
| config | Config options as in the ones we pass in juju config | `map(string)` | `{}` | no |
| constraints | Constraints to be applied | `string` | `""` | no |
| revision | Charm revision | `number` | `null` | no |
| units | Number of units | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_name | The name of the deployed application |
| provides | The integration endpoints provided by the application |
| requires | The integration endpoints required by the application |
<!-- END_TF_DOCS -->
