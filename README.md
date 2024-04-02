# rob-cos-overlay

The rob-cos overlay is an overlay bundle for [cos-lite](https://github.com/canonical/cos-lite-bundle/tree/main).
The robotics overlay customises the upstream COS lite bundle to observe robotics devices.

To deploy the rob-cos bundle follow these instructions:

Clone the source repository:

```
git clone https://github.com/ubuntu-robotics/rob-cos-overlay.git
```

Deploy as follows:

```
juju deploy cos-lite --trust --overlay ./robotics-overlay.yaml
```
