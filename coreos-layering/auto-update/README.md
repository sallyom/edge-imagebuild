## Bootable container images with autoupdate systemd service

This is using Colin Walters's [autonomous-podman-hello](https://gitlab.com/CentOS/cloud/sagano-examples/-/tree/main/autonomous-podman-hello?ref_type=heads)

### What's it doing?

This example shows an "immutable infrastructure" model with bootable container images.
Instead of delivering OS updates in a traditional way, this packages and delivers
OS images as OCI objects. With podman-autoupdate the system is updated by pushing a new image to
a registry - when it changes, the host will automatically fetch it and reboot with
`rpm-ostree upgrade --reboot`. 

### Benefits

All the tried and true OCI image tools can be utilized to streamline and simplify OS updates
Discourage infrastructure drift with atomic upgrades.

If you are intrigued, you might also check out:

2. [CoreOS layering examples](https://github.com/coreos/layering-examples)
3. [Universal Blue](https://universal-blue.org/)
4. [OSTree](https://ostreedev.github.io/ostree/#operating-systems-and-distributions-using-ostree)
5. [bootc](https://github.com/containers/bootc/tree/main)
