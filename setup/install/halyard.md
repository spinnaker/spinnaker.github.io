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

Halyard is the tool responsible for managing your Spinnaker deployment's
lifecycle. This includes writing & validating your deployment's configuration,
deploying each of Spinnaker's subcomponents, and performing updates to your
deployment of Spinnaker.

All non-quickstart deployments of Spinnaker require Halyard to manage
configuration, installation, and updates of Spinnaker. While it is possible to
install Spinnaker without Halyard, we do not recommend it, and if you get stuck
we will encourage you to instead use Halyard.

## Installation

There are a few different ways to install Halyard (with more on the way):

### Ubuntu 14.04/16.04

Note: While Halyard is supported on Ubuntu 16.04 the current release of Spinnaker
is not.

The following command installs the latest released Halyard version, and will
prompt the user for some configuration in the process. Generally the default
answers to each prompt are best.

```bash
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

sudo bash InstallHalyard.sh
```

At this point, run the following command to see if Halyard was installed
properly.

```bash
hal -v
```

If that command fails, make sure `hal` is in your `$PATH`, and check for logs
under `/var/log/spinnaker/halyard/halyard.log`.

### Docker

> This installation path is in alpha and will have some rough edges.

Make sure you have [Docker CE
installed](https://docs.docker.com/engine/installation/). 

Fetch the latest Halyard version:

```bash
docker pull gcr.io/spinnaker-marketplace/halyard:stable
```

Make (on your current machine) a local Halyard config directory. This will
persist between runs of the Halyard docker container.

```bash
mkdir ~/.hal
```

Now, run the Halyard docker container, while mounting that Halyard config
directory for your container:

```
docker run -p 8084:8084 -p 9000:9000 \
    --name halyard --rm \
    -v ~/.hal:/root/.hal \
    -it \
    gcr.io/spinnaker-marketplace/halyard:stable
```

This will emit all of the Halyard daemon's logs, and run as a foreground
process in your current shell.

In a separate shell, run:

```
docker exec -it halyard bash
```

Now you're able to interact with the Halyard daemon. __However__, any
secrets/config you need to supply to the daemon (e.g. a kubeconfig file) will
need to be mounted in either your local `~/.hal` directory, or another
directory that you supply to `docker run` with additional `-v` command-line 
options.

## Command-Completion & Help

If you're ever stuck, appending `-h` to a command will provide some help text
to explain what a command does. If you're still stuck, try looking under the
[reference documentation](/reference/halyard).

Halyard also supplies a fair amount of command-completion; if you haven't
already, run the following command or restart your shell to enable it.

```bash
. ~/.bashrc
```

## Updates

If you're running a version of Halyard before 0.40.0, you can run:

```bash
sudo apt-get update
sudo apt-get install spinnaker-halyard
```

Otherwise, run:

```bash
sudo update-halyard
```

## Uninstalling Halyard

If you've used Halyard to deploy Spinnaker, and want to first purge that
deployment, run the following command.

```bash
hal deploy clean
```

At this point you can safely uninstall Halyard by running the following
command.

```bash
~/.hal/uninstall.sh
```

## Next Steps

Once Halyard is installed and running, it's time to decide which [environment to
deploy](/setup/install/environment/) Spinnaker to.
