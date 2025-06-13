# Terraform module for `rob-cos`

This is a Terraform module facilitating the deployment of the COS for Devices project,
using the [Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

> [!CAUTION]
> This module is not intended to be deployed in production.
> It rather is a demonstrator as well as a starting point for developing a production-grade configuration.

## Requirements

This module requires both a Juju machine model as well as a Juju K8s model to be available.
Refer to the [usage section](#usage) below for more details.

## Usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run:

```bash
terraform apply -var="robcos_model=<K8S_MODEL_NAME>" -var="microceph_model=<MACHINE_MODEL_NAME>"
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
| cos\_lite | git::https://github.com/canonical/observability//terraform/modules/cos-lite | n/a |
| microceph | ../../modules/microceph | n/a |
| robcos\_overlay | ../../modules/robcos_overlay | n/a |

## Resources

| Name | Type |
|------|------|
| [juju_integration.catalogue_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.catalogue_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_dashboard_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_dashboard_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_dashboard_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress_microceph](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.logging_alert_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.logging_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.logging_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.send_remote_write_alerts_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.tracing_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.tracing_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_offer.microceph](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/offer) | resource |
| [juju_model.microceph_model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |
| [juju_model.robcos_model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| microceph\_model | Model name (must be a machine model) | `string` | n/a | yes |
| robcos\_model | Model name (must be a k8s model) | `string` | n/a | yes |
| cos\_lite | The cos-lite variables. Please refer to the module for more information. | ```object({ channel = optional(string, "latest/edge") use_tls = optional(bool, false) })``` | `{}` | no |
| cos\_registration\_server | The cos-registration-server variables. Please refer to the module for more information. | ```object({ channel = optional(string, "latest/edge") revision = optional(number, null) })``` | `{}` | no |
| foxglove\_studio | The foxglove-studio variables. Please refer to the module for more information. | ```object({ channel = optional(string, "latest/edge") revision = optional(number, null) })``` | `{}` | no |
| microceph | The microceph variables. Please refer to the module for more information. | ```object({ channel = optional(string, "squid/stable") revision = optional(number, null) units = optional(number, 3) })``` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_names | The names of the deployed applications |
| cos\_lite | Outputs from the COS lite module |
| microceph | Outputs from the microceph module |
| robcos\_overlay | Outputs from the robcos-overlay module |
<!-- END_TF_DOCS -->
