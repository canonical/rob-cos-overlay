# Terraform module for `microceph`

This is a Terraform module facilitating the deployment of the `microceph` charm,
using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/).
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
<!-- END_TF_DOCS -->
