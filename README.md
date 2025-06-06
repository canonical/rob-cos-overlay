# rob-cos-overlay

The rob-cos overlay is an overlay bundle for [cos-lite](https://github.com/canonical/cos-lite-bundle).
The robotics overlay customises the upstream COS lite bundle to observe robotics devices.

## Use

### Terraform

This repository contains a collection of Terraform configurations to ease the deployment of COS for devices.
Most notably it contains:

- a Terraform module for deploying [microceph](./terraform/modules/microceph/README.md)
- a Terraform module for deploying the [rob-cos](./terraform/modules/rob-cos-overlay/README.md) overlay
- a demonstration Terraform module for deploying a fully working [rob-cos](./terraform/dev/rob-cos/README.md) project

### Juju bundle

> [!WARNING]
> Juju bundles are being deprecated.
> Please use [Terraform](#terraform) instead.

To deploy the rob-cos bundle follow these instructions:

Clone the source repository:

```bash
git clone https://github.com/ubuntu-robotics/rob-cos-overlay.git
```

Deploy as follows:

```bash
juju deploy cos-lite --trust --overlay ./robotics-overlay.yaml
```
