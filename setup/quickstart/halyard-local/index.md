---
layout: single
title:  "Halyard on your local machine Quickstart"
sidebar:
  nav: setup
---

{% include toc %}

In this quickstart, you will learn the basics of [Halyard](/setup/install/halyard/), Spinnaker's tool for managing your Spinnaker instance.

NOTE: This Quickstart guide assumes you are running Ubuntu 14.04 LTS, but the process should be similar for other unix operating systems.

## Overview

In our scenario, we want to create a Spinnaker instance and set it up as follows:

* The Spinnaker instance is itself running on your local machine
* Spinnaker is downloaded from github, and built locally.
* We use redis as our persistance store

## Part 0: Prerequisites

Ensure that the following are installed on your system

* git
* curl
* yarn ([guide](https://yarnpkg.com/lang/en/docs/install/))

Fork all of the microservices listed here: [Spinnaker Microservices](https://www.spinnaker.io/reference/architecture/#spinnaker-microservices) on github.

Follow the following guides to setup ssh access to your github.com account from your local machine.

* [Generating a new ssh key and adding it to your ssh agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
* [Adding a new ssh key to your Github account](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

## Part 1: Installing Halyard

```bash
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

sudo bash InstallHalyard.sh

. ~/.bashrc
```

## Part 2: Configure Halyard

Configure Halyard to use your github.com username.

```bash
hal config deploy edit --git-origin-user=<YOUR_GITHUB_USERNAME>
```

Configure Halyard to configure a LocalGit type deployment.

```bash
hal config deploy edit --type LocalGit
```

Configure Halyard to generate a local Spinnaker that relys on Redis for persistant storage.

*NOTE: You need access to a Redis server at localhost:6379. Using a ssh tunnel to a remote Redis service is recommended.*

```bash
hal config storage edit --type redis
```

Configure Halyard to deploy the latest stable version of Spinnaker

```bash
hal config version edit --version $(hal version latest -q)
```

## Part 3: Deploy Spinnaker

Use Halyard to deploy Spinnaker

```bash
sudo hal deploy apply
```