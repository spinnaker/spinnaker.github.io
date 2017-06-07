---
layout: single
title:  "Halyard"
sidebar:
  nav: setup
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

Currently Halyard may only be installed on Ubuntu 14.04.

The following command installs the latest released Halyard version, and will
prompt the user for some configuration in the process. Generally the default
answers to each prompt are best.

```bash
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/stable/InstallHalyard.sh

sudo bash InstallHalyard.sh
```

At this point, run the following command to see if Halyard was installed
properly.

```bash
hal -v
```

If that command fails, make sure `hal` is in your `$PATH`, and check for logs
under `/var/log/upstart/halyard` and `/var/log/spinnaker/halyard/halyard.log`.

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

You can always update Halyard by running the following commands.

```bash
sudo apt-get update
sudo apt-get upgrade spinnaker-halyard
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
