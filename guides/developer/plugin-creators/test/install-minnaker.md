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

1. Revert Spinnaker to 1.20.6

	```bash
   hal config version edit --version 1.20.6
	hal deploy apply
	```

1. Configure Minnaker to listen on all ports

   ```bash
   ./minnaker/scripts/utils/expose_local.sh
   ```

   This creates a load balancer for each service. Console output is similar to:

	```bash
	NAME                                READY   STATUS    RESTARTS   AGE
   minio-0                             1/1     Running   0          18h
   mariadb-0                           1/1     Running   0          18h
   halyard-0                           1/1     Running   0          18h
   spin-redis-664df6f896-b5px8         1/1     Running   0          18h
   svclb-spin-clouddriver-lcmrq        1/1     Running   0          10m
   svclb-spin-redis-24qf6              1/1     Running   0          10m
   svclb-spin-front50-8hchk            1/1     Running   0          10m
   svclb-spin-orca-9t89s               1/1     Running   0          10m
   svclb-spin-gate-gn6g5               1/1     Running   0          10m
   svclb-spin-deck-26vpf               1/1     Running   0          10m
   svclb-spin-echo-s6zdv               1/1     Running   0          10m
   svclb-spin-rosco-qwfhv              1/1     Running   0          10m
   spin-deck-55b88d5fb9-v2ngf          1/1     Running   0          10m
   spin-front50-8fd4f9459-fwpzc        1/1     Running   0          10m
   spin-rosco-6885b6df45-jqkl9         1/1     Running   0          10m
   spin-gate-75df95744b-7zvp5          1/1     Running   0          10m
   spin-orca-766f9bbf7b-cw9f7          1/1     Running   0          10m
   spin-echo-9bbcd9df8-td4rt           1/1     Running   0          10m
   spin-clouddriver-55bc94ddcc-4d7cd   1/1     Running   0          10m