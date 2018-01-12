---
layout: single
title:  "Choose your Environment"
sidebar:
  nav: setup
---

{% include toc %}

There are several environments Halyard can deploy Spinnaker to, and they can be 
split into three groups, each entirely handled by Halyard.

* [Local installations](#local-debian) of Debian packages.
* [Distributed installations](#distributed) via a remote bootstrapping process.
* [Local git installations](#local-git) from github.

## Local Debian

The __Local Debian__ installation means Spinnaker will be downloaded and run on the 
single machine Halyard is currently installed on.

### Intended Use-case

The __Local Debian__ installation is intended for smaller deployments of Spinnaker,
and for clouds where the __Distributed__ installation is not yet supported;
however, since all services are on a single machine, there will be downtime when
Halyard updates Spinnaker.

### Required Hal Invocations

Currently, Halyard defaults to a __Local Debian__ install when first run,
and no changes are required on your behalf. However, if you've edited
Halyard's deployment type and want to revert to a local install, you can run
the following command.

```
hal config deploy edit --type localdebian
```

## Distributed

The __Distributed__ installation means that Spinnaker will be deployed to a 
remote cloud such that each of Spinnaker's services are deployed 
independently. This allows Halyard to manage Spinnaker's lifecycle by creating 
a smaller, headless Spinnaker to update your Spinnaker, ensuring 0 downtime 
updates.

### Intended Use-case

This installation is intended for users with a larger resource footprint, and
for those who can't afford downtime during Spinnaker updates.

### Required Hal Invocations

First, you need to configure one of the Cloud Providers that supports the
__Distributed__ installation:

* <a href="/setup/providers/kubernetes" target="_blank">Kubernetes</a> **Note**: We recommend having at least 4 cores and 8 GiB of RAM free in the cluster you are deploying to.
* <a href="/setup/providers/gce" target="_blank">Google Compute Engine</a> :warning: This is still in beta

Then, remembering the `$ACCOUNT` name that you've created during the
Provider configuration, run

```
hal config deploy edit --type distributed --account-name $ACCOUNT
```

This command changes the type of the next deployment of Spinnaker, and will
deploy it to the account you have previously configured.

## Local Git

The __Local Git__ installation means Spinnaker will be cloned, built, and run on
the single machine Halyard is run on.

### Intended Use-case

The __Local Git__ installation is intended for developers who want to contribute
to Spinnaker. It is not intended to be used to manage any production environment.

### Prerequisites

#### Install local dependencies

Ensure that the following are installed on your system:

* git
* curl
* redis-server
* node (version >=8.9.0, [can be installed via nvm](https://github.com/creationix/nvm#install-script))
* yarn (`npm install -g yarn` or [guide](https://yarnpkg.com/lang/en/docs/install/))


#### Fork all Spinnaker repos

Fork all of the microservices listed here: [Spinnaker Microservices](https://www.spinnaker.io/reference/architecture/#spinnaker-microservices) on github ([guide](https://guides.github.com/activities/forking/#fork)).

#### Setup SSH Keys

Follow these guides to setup ssh access to your github.com account from your local machine:

* [Generating a new ssh key and adding it to your ssh agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
* [Adding a new ssh key to your Github account](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

### Required Hal Invocations

Currently, Halyard defaults to a __Local Debian__ install when first run, so 
Developers must change their deployment type to __Local Git__ type. You can run 
the following command.

```
hal config deploy edit --type localgit --git-origin-user=<YOUR_GITHUB_USERNAME>
```

*NOTE: Be sure to use the same username here that you forked the Spinnaker repositories to*

## Further Reading

* [Spinnaker Architecture](/reference/architecture/) for a better understanding
  of the Distributed installation.

## Next Steps

Now that your deployment environment is set up, you need to provide Spinnaker
with a [Persistent Storage](/setup/install/storage/) source.
