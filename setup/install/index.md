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
  it can be a Docker container. Make sure it has at least 4GB of memory.

* A Kubernetes cluster on which to install Spinnaker itself

  We recommend at least 4 cores and 8GB of RAM available in the cluster. 

You can also install [on a single local machine](https://www.spinnaker.io/setup/install/environment/#local-debian), or [for Spinnaker development](https://www.spinnaker.io/setup/install/environment/#local-git), making sure you have the 4 cores and 8GB in each case. 

## The process

Installing a complete Spinnaker involves these steps:
1. [Install Halyard](/setup/install/halyard/)
1. [Choose a cloud provider](/setup/install/providers/)
1. [Choose an environment](/setup/install/environment/)
1. [Choose a storage service](/setup/install/storage/)
1. [Deploy Spinnaker](/setup/install/deploy/)
1. [Back up your config](/setup/install/backups/)
1. [Configure everything else](/setup/other_config/) (which includes a lot of
  stuff you need before you can use Spinnaker in production)
1. [Productionize Spinnaker](/setup/productionize/) (which mainly helps you
  configure Spinnaker to scale for production)

## And then what?

[Get started using Spinnaker](/guides/user/get-started)
