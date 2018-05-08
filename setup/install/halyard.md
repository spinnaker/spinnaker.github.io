---
layout: single
title:  "Install Halyard"
sidebar:
  nav: setup
redirect_from:
  - /docs/creating-a-spinnaker-instance
  - /docs/target-deployment-configuration
---

{% include toc %}

Halyard manages the lifecycle of your Spinnaker deployment, including writing &
validating your deployment's configuration, deploying each of Spinnaker's
microservices, and updating the deployment.

All production-capable deployments of Spinnaker require Halyard in order to
install, configure, and update Spinnaker. Though it's possible to install
Spinnaker without Halyard, we don't recommend it, and if you get stuck we're
just going to tell you to use Halyard.

There are two ways you can install Halyard:

* [on Docker](#install-halyard-on-docker)

  Docker installation is strongly recommended.

* [on Ubuntu](#install-on-ubuntu-14041604)

  We support installation on 14.04 and 16.04. Installing on 16.04 requires
  Spinnaker 1.6.0 or later.

## Install Halyard on Docker

1. Make sure you have [Docker CE
installed](https://docs.docker.com/engine/installation/).

1. On your current machine, make a local Halyard config directory.

   This will persist between runs of the Halyard docker container.

   ```bash
   mkdir ~/.hal
   ```

1. Run the Halyard Docker container, mounting that Halyard config directory for
your container:

   ```
   docker run -p 8084:8084 -p 9000:9000 \
       --name halyard --rm \
       -v ~/.hal:/home/spinnaker/.hal \
       -it \
       gcr.io/spinnaker-marketplace/halyard:stable
   ```

   This runs as a foreground process in your current shell. This is useful
   because it emits all of the Halyard daemon's logs, which are not persisted.
   If you don't care about the logs, and would rather run in detached mode,
   replace the `-it` with `-d`

   > __Note:__ Any secrets/config you need to supply to the daemon (for example, a
   > kubeconfig file) must be mounted in either your local `~/.hal` directory, or
   > another directory that you supply to `docker run` with additional `-v`
   > command-line options.

1. In a separate shell, connect to Halyard running in the container:

   ```
   docker exec -it halyard bash
   ```

   You can interact with Halyard from here.

1. Run the following command to enable command completion:

   ```bash
   source <(hal --print-bash-completion)
   ```

To get help with any `hal` command, append `-h`. Also, see the [Halyard command
Reference](/reference/halyard/commands).

<span class="begin-collapsible-section"></span>

### Update Halyard on Docker

1. Fetch the latest Halyard version.

   ```bash
   docker pull gcr.io/spinnaker-marketplace/halyard:stable
   ```

1. Stop the running Halyard container.

   `docker stop halyard`

1. Re-run the container:

   ```
   docker run -p 8084:8084 -p 9000:9000 \
       --name halyard --rm \
       -v ~/.hal:/home/spinnaker/.hal \
       -it \
       gcr.io/spinnaker-marketplace/halyard:stable
   ```

   This re-starts the container using the updated image you got in step 1.

1. In a separate shell, run:

   ```
   docker exec -it halyard bash
   ```

<span class="end-collapsible-section"></span>

<span class="begin-collapsible-section"></span>

### Uninstall Halyard from Docker

To uninstall Halyard, just delete the container.

` docker rm halyard`

<span class="end-collapsible-section"></span>


<span class="begin-collapsible-section"></span>

## Install on Ubuntu 14.04/16.04

> __Note__: Ubuntu 16.04 is supported for Spinnaker versions 1.6.0 and later.

1. Get the latest version of Halyard:

   `curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh`

1. Install it:

   `sudo bash InstallHalyard.sh`

   If you're prompted for any information, default answers are usually suitable.

1. Check whether Halyard was installed properly:

   `hal -v`

   If this command fails, make sure `hal` is in your `$PATH`, and check the logs
under `/var/log/spinnaker/halyard/halyard.log`.

1. Run `. ~/.bashrc` to enable command completion.

To get help with any `hal` command, append `-h`. Also, see the [Halyard command
Reference](/reference/halyard/commands).

### Update Halyard on Ubuntu

If you're running a version of Halyard before 0.40.0, run these commands:

```bash
sudo apt-get update
sudo apt-get install spinnaker-halyard
```

Otherwise, run this one:

```bash
sudo update-halyard
```

### Uninstall Halyard from Ubuntu

If you used Halyard to deploy Spinnaker, and you want to purge that deployment,
run the following command:

```bash
hal deploy clean
```

Now you can safely uninstall Halyard:

```bash
sudo ~/.hal/uninstall.sh
```
<span class="end-collapsible-section"></span>

## Next steps

Now that Halyard is running, it's time to decide which [environment to
deploy](/setup/install/environment/) Spinnaker to.
