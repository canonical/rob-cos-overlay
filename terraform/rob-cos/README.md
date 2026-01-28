# Terraform module for `rob-cos`

This is a Terraform module facilitating the deployment of the COS for Devices project,
using the [Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

> [!CAUTION]
> This module is not intended to be deployed in production.
> It rather is a demonstrator as well as a starting point for developing a production-grade configuration.

## Usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run:

```bash
terraform apply -var="model=<K8S_MODEL_NAME>"
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

## Modules

| Name | Source | Version |
|------|--------|---------|
| blackbox\_exporter | git::https://github.com/ubuntu-robotics/blackbox-exporter-k8s-operator//terraform | feat/terraform |
| cos\_lite | git::https://github.com/canonical/observability-stack//terraform/cos-lite | n/a |
| cos\_registration\_server | git::https://github.com/canonical/cos-registration-server-k8s-operator//terraform | n/a |
| foxglove\_studio | git::https://github.com/ubuntu-robotics/foxglove-k8s-operator//terraform | n/a |

## Resources

| Name | Type |
|------|------|
| [juju_integration.catalogue_blackbox_exporter](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.catalogue_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.catalogue_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_dashboard_blackbox_exporter](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_dashboard_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress_blackbox_exporter](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress_foxglove_studio](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.logging_alert_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.probes_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.self_metrics_endpoint_blackbox_exporter](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.send_remote_write_alerts_devices_cos_registration_server](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_model.model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| model | Name of the model to deploy to (must be a K8s model) | `string` | n/a | yes |
| blackbox\_exporter | Application configuration for Blackbox Exporter. For more details: https://github.com/ubuntu-robotics/blackbox-exporter-k8s-operator/tree/feat/terraform/terraform | ```object({ app_name = optional(string, "blackbox-exporter") channel = optional(string, "1/stable") config = optional(map(string), {}) constraints = optional(string, "arch = amd64") revision = optional(number, null) units = optional(number, 1) })``` | `{}` | no |
| cos\_lite | Applications configurations for COS Lite. For more details: https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite | ```object({ channel = optional(string, "1/stable") internal_tls = optional(bool, false) })``` | `{}` | no |
| cos\_registration\_server | Application configuration for COS Registration Server. For more details: https://github.com/ubuntu-robotics/cos-registration-server-k8s-operator/tree/main/terraform | ```object({ app_name = optional(string, "cos-registration-server") channel = optional(string, "latest/edge") config = optional(map(string), {}) constraints = optional(string, "arch = amd64") revision = optional(number, null) storage_directives = optional(map(string), {}) units = optional(number, 1) })``` | `{}` | no |
| foxglove\_studio | Application configuration for Foxglove Studio. For more details: https://github.com/ubuntu-robotics/foxglove-k8s-operator/tree/main/terraform | ```object({ app_name = optional(string, "foxglove-studio") channel = optional(string, "latest/edge") config = optional(map(string), {}) constraints = optional(string, "arch = amd64") revision = optional(number, null) storage_directives = optional(map(string), {}) units = optional(number, 1) })``` | `{}` | no |
| model\_owner | The owner of the model to deploy to | `string` | `"admin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_names | The names of the deployed applications |
| components | Outputs of the deployed applications |
<!-- END_TF_DOCS -->
