## Install Spinnaker in a Multipass VM

 Minnaker is an open source tool that installs the latest release of Spinnaker and Halyard on [Lightweight Kubernetes (K3s)](https://k3s.io/).

1. Launch a Multipass VM with 2 cores, 10GB of memory, 30GB of storage

   ```bash
   multipass launch -c 2 -m 10G -d 30G
   ```

1. Get the name of your VM

   ```bash
   multipass list
   ```

1. Access your VM

   ```bash
   multipass shell <vm-name>
   ```

1. Download and unpack Minnaker

   ```bash
   curl -LO https://github.com/armory/minnaker/releases/download/0.0.20/minnaker.tgz
   tar -xzvf minnaker.tgz
   ```

1. Install Spinnaker

   The `minnaker/scripts` directory contains multiple scripts. Use the `no_auth_install` script to install Spinnaker in no-auth mode so you can access Spinnaker without credentials. **Be sure to use the `-o` option** to install the open source version of Spinnaker rather than Armory Spinnaker.

   ```bash   
   ./minnaker/scripts/no_auth_install.sh -o
   ```

   If you accidentally forget the `-o` option, run `./minnaker/scripts/switch_to_oss.sh` to install open source Spinnaker.

   The script prints out the IP address of Minnaker after installation is complete.

   Check pod status:

   ```bash
   kubectl -n spinnaker get pods
   ```

   Minnaker forwards `hal` commands to the Halyard pod so you don't need to access the pod itself.

   Consult the Minnaker [README](https://github.com/armory/minnaker/blob/master/readme.md#changing-your-spinnaker-configuration) for basic troubleshooting information if you run into issues.

1. Configure Minnaker to listen on all ports:

   ```bash
   ./minnaker/scripts/utils/expose_local.sh
   ```
