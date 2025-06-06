# Terraform module for the COS for devices overlay

This is a Terraform module facilitating the deployment of the COS for devices charms
on top of [COS-lite](https://github.com/canonical/observability/blob/main/terraform/modules/cos-lite),
using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

## Requirements

This module requires a Juju k8s model to be available.
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

## Modules

| Name | Source | Version |
|------|--------|---------|
| cos\_registration\_server | git::https://github.com/canonical/cos-registration-server-k8s-operator//terraform | n/a |
| foxglove\_studio | git::https://github.com/ubuntu-robotics/foxglove-k8s-operator//terraform | n/a |

## Resources

| Name | Type |
|------|------|
| [juju_model.model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| model | Model name (must be a k8s model) | `string` | n/a | yes |
| cos\_registration\_server | The cos-registration-server variables. Please refer to the module for more information. | ```object({ channel = optional(string, "latest/edge") revision = optional(number, null) })``` | `{}` | no |
| foxglove\_studio | The foxglove-studio variables. Please refer to the module for more information. | ```object({ channel = optional(string, "latest/edge") revision = optional(number, null) })``` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_names | The names of the deployed applications |
| cos\_registration\_server | Outputs from the COS registration server module |
| foxglove\_studio | Outputs from the Foxglove Studio module |
<!-- END_TF_DOCS -->
