# Terraform module for `rob-cos`

This is a Terraform module facilitating the deployment of the COS for Devices project,
using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/).
For more information,
refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

> [!CAUTION]
> This module is not intended to be deployed in production.
> It rather is a demonstrator as well as a starting point for developing a production-grade configuration.

## Requirements

This module requires both a Juju machine model as well as a Juju k8s model to be available.
Refer to the [usage section](#usage) below for more details.

## Usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run:

```bash
terraform apply -var="robcos_model=<K8S_MODEL_NAME>" -var="microceph_model=<MACHINE_MODEL_NAME>"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
