---
layout: single
title:  "Environment"
sidebar:
  nav: setup
---

{% include toc %}

There are several environments Halyard can deploy Spinnaker to, and they can be 
split into two groups, both entirely handled by Halyard.

* [Local installations](#local) of Debian packages.
* [Distributed installations](#distributed) via a remote bootstrapping process.

## Local

The __Local__ installation means Spinnaker will be downloaded and run on the 
single machine Halyard is currently installed on.

### Intended Use-case

The __Local__ installation is intended for smaller deployments of Spinnaker,
and for clouds where the __Distributed__ installation is not yet supported;
however, since all services are on a single machine, there will be downtime when
Halyard updates Spinnaker.

### Required Hal Invocations

Currently, Halyard defaults to a __Local__ install when first run,
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

* <a href="/setup/providers/kubernetes" target="_blank">Kubernetes</a>
* <a href="/setup/providers/gce" target="_blank">Google Compute Engine</a> :warning: This is still in beta

Then, remembering the `$ACCOUNT` name that you've created during the
Provider configuration, run

```
hal config deploy edit --type distributed --account-name $ACCOUNT
```

This command changes the type of the next deployment of Spinnaker, and will
deploy it to the account you have previously configured.

## Further Reading

* [Spinnaker Architecture](/reference/architecture) for a better understanding
  of the Distributed installation.

## Next Steps

Now that your deployment environment is set up, you need to provide Spinnaker
with a [Persistent Storage](/setup/install/storage) source.
