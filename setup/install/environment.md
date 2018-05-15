---
layout: single
title:  "__3__. Choose your Environment"
sidebar:
  nav: setup
---

{% include toc %}

In this step, you tell Halyard where to install Spinnaker.

* [Distributed installation](#distributed-installation)
  Halyard deploys each of Spinnaker's [microservices](/reference/architecture)
  separately. This is highly recommended for use in production.

* [Local installations](#local-debian) of Debian packages
  Spinnaker is deployed on a single machine. This is good for smaller
  deployments.

* [Local git installations](#local-git) from github.
  This is useful for developers contributing to the Spinnaker project.

  The recommended path is a distributed installation onto a Kubernetes cluster,
  but all of these methods are supported:

## Distributed installation

Distributed installations are for development orgs with large resource
footprints, and for those who can't afford downtime during Spinnaker updates.

Spinnaker is deployed to a remote cloud, with each
[microservice](/reference/architecture/) deployed independently. Halyard
creates a smaller, headless Spinnaker to update your Spinnaker and its
microservices, ensuring zero-downtime updates.

1. If you haven't already done so, configure a provider for the environment in
which you will install Spinnaker.

   This must be on a Kubernetes cluster. It does not have to be the same
   provider as the one you're using to deploy your applications.

   * [Kubernetes](/setup/install/providers/kubernetes)

   * [Kubernetes (Manifest Based)](/setup/install/providers/kubernetes-v2)<br />
     :warning: This is still in alpha.

   We recommend at least 4 cores and 8GB of RAM available in the cluster where
   you will deploy Spinnaker.

1. Run the following command, using the `$ACCOUNT` name you created when you
configured the provider:

   ```
   hal config deploy edit --type distributed --account-name $ACCOUNT
   ```

<span class="begin-collapsible-section"></span>

## Local Debian

The __Local Debian__ installation means Spinnaker will be downloaded and run on the
single machine Halyard is currently installed on.

### Intended use case

The __Local Debian__ installation is intended for smaller deployments of Spinnaker,
and for clouds where the __Distributed__ installation is not yet supported;
however, since all services are on a single machine, there will be downtime when
Halyard updates Spinnaker.

Note that a Halyard [Docker
installation](https://www.spinnaker.io/setup/install/halyard/#docker) cannot be
used as a __Local Debian__ base image because it does not contain the necessary
packages to run Spinnaker.

### Required Halyard invocations

Currently, Halyard defaults to a __Local Debian__ install when first run,
and no changes are required on your behalf. However, if you've edited
Halyard's deployment type and want to revert to a local install, you can run
the following command.

```
hal config deploy edit --type localdebian
```

<span class="end-collapsible-section"></span>

<span class="begin-collapsible-section"></span>

## Local Git

The __Local Git__ installation means Spinnaker will be cloned, built, and run on
the single machine Halyard is run on.

### Intended use case

The __Local Git__ installation is intended for developers who want to contribute
to Spinnaker. It is not intended to be used to manage any production environment.

### Prerequisites

#### Install local dependencies

Ensure that the following are installed on your system:

* git
* curl
* redis-server
* OpenJDK 8 - JDK (we're building from source, so a JRE is not sufficient)
* node (version >=8.9.0, [can be installed via nvm](https://github.com/creationix/nvm#install-script))
* yarn (`npm install -g yarn` or [guide](https://yarnpkg.com/lang/en/docs/install/))


#### Fork all Spinnaker repos

Fork all of the microservices listed here: [Spinnaker Microservices](https://www.spinnaker.io/reference/architecture/#spinnaker-microservices) on github ([guide](https://guides.github.com/activities/forking/#fork)).

#### Setup SSH keys

Follow these guides to setup ssh access to your github.com account from your local machine:

* [Generating a new ssh key and adding it to your ssh agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
* [Adding a new ssh key to your Github account](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

### Required Halyard invocations

Halyard defaults to a __Local Debian__ install when first run. If you will be
contributing code to the Spinnaker project, you can change your deployment type
to __Local Git__ type and set up your development environment with the latest
code.

```
hal config deploy edit --type localgit --git-origin-user=<YOUR_GITHUB_USERNAME>

hal config version edit --version branch:upstream/master
```

*NOTE: Be sure to use the same username here that you forked the Spinnaker repositories to*

<span class="end-collapsible-section"></span>

## Further reading

* [Spinnaker Architecture](/reference/architecture/) for a better understanding
  of the Distributed installation.

## Next steps

Now that your deployment environment is set up, you need to provide Spinnaker
with a [Persistent Storage](/setup/install/storage/) source.
