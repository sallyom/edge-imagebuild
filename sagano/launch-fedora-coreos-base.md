### Start a FedoraCoreOS instance in AWS

Edit the [ignition file](./config.ign) for your instance. Refer to [ignition examples](https://coreos.github.io/ignition/examples/#add-users)

This script assumes you have `aws cli` installed and configured with your cloud account.

```bash
./launch-aws.sh
```
