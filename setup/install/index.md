---
layout: single
title:  "Install and Configure Spinnaker"
sidebar:
  nav: setup
redirect_from: /docs/installation-tools
---

This section describes how to install and set up Spinnaker so that it can be configured for
use in production. If you just want to evaluate Spinnaker without much work, one of the options
in [Quickstart](/setup/quickstart/) might be a better choice.

## What you'll need

* A machine on which to install Halyard

  This can be a local machine or VM (Ubuntu 14.04/16.04, Debian, or macOS), or
  it can be a Docker container.

* A Kubernetes cluster on which to install Spinnaker itself

## The process

Installing a complete Spinnaker involves these steps:
1. [Install Halyard](/setup/install/halyard/)
2. [Choose a cloud provider](/setup/install/providers/)
3. [Choose an environment](/setup/install/environment/)
4. [Deploy Spinnaker](/setup/install/deploy/)

## Next steps

Let's start by [setting up Halyard](/setup/install/halyard/), which will manage
the configuration, installation, and updates of Spinnaker for you.

After this process is done, you can use Spinnaker to create pipelines and deploy software,
but there are some [further configuration steps](/setup/other_config/) you're likely to need.
