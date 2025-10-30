# Terraform module for `rob-cos-microceph`

This is a Terraform module facilitating the deployment of the COS for Devices project with a MicroCeph storage backend,
using the [Terraform Juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

> [!CAUTION]
> This module is not intended to be deployed in production.
> It rather is a demonstrator as well as a starting point for developing a production-grade configuration.

> [!IMPORTANT]
> This module deploys two stacks on both a machine model as well as a K8s model.
> Both models must be available.
> They may be managed by the same controller, or two diffferent controllers.
> Refer to the [usage section](#usage) below for more details.

## Usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run:

```bash
terraform apply -var="robcos_model=<K8S_MODEL_NAME>" -var="microceph_model=<MACHINE_MODEL_NAME>"
```

### On destroy

There is currently a [bug](https://github.com/juju/terraform-provider-juju/issues/721) that prevents from seamlessly destroying a deployment.
To work around that bug, we have to manually remove an integration from both `juju` and the Terraform state.
To do so:

```bash
juju remove-relation traefik:traefik-route microceph:traefik-route-rgw --model <robcos-model>
terraform state rm juju_integration.ingress_microceph
```

We can then destroy the deployment as usual with `terraform destroy`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| juju | < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| juju.microceph | < 2.0.0 |
| juju.robcos | < 2.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| microceph | ../microceph | n/a |
| rob\_cos | ../rob-cos | n/a |

## Resources

| Name | Type |
|------|------|
| [juju_integration.ingress_microceph](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_offer.microceph](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/offer) | resource |
| [juju_model.microceph_model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |
| [juju_model.robcos_model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| microceph\_model | Name of the machine model to deploy MicroCeph to | `string` | n/a | yes |
| robcos\_model | Name of the K8s model to deploy rob-cos to | `string` | n/a | yes |
| cos\_lite | The cos-lite variables. Please refer to the module for more information. | ```object({ channel = optional(string, "1/stable") use_tls = optional(bool, false) })``` | `{}` | no |
| microceph | The MicroCeph variables. Please refer to the module for more information. | ```object({ channel = optional(string, "squid/stable") revision = optional(number, null) units = optional(number, 3) })``` | `{}` | no |
| microceph\_controller | The Juju controller credentials for the controller managing the machine model where MicroCeph is to be deployed | ```object({ addresses = optional(string) username = optional(string) password = optional(string) ca_certificate_path = optional(string) })``` | `{}` | no |
| rob\_cos | The rob-cos variables. Please refer to the module for more information. | ```object({ # channel = optional(string, "latest/edge") })``` | `{}` | no |
| robcos\_controller | The Juju controller credentials for the controller managing the K8s model where rob-cos is to be deployed | ```object({ addresses = optional(string) username = optional(string) password = optional(string) ca_certificate_path = optional(string) })``` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_names | The names of the deployed applications |
| components | Outputs of the deployed applications |
<!-- END_TF_DOCS -->
