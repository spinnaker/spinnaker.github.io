---
layout: single
title:  "Deploy Spinnaker and Connect to the UI"
sidebar:
  nav: setup
redirect_from: /setup/install/upgrades/
---

Now that we've enabled one or more [Cloud Providers](/setup/providers/), picked
a [Deployment Environment](/setup/install/environment/), and configured
[Persistent Storage](/setup/install/storage/), we're ready to pick a version of
Spinnaker, deploy it, and connect to it.

## Pick a version

1. List the available versions:

   ```bash
   hal version list
   ```

   You can follow the links to the versions' respective changelogs to see what
   features each adds.

1. Set the version you want to use:

   ```bash
   hal config version edit --version $VERSION
   ```

## Deploy Spinnaker

```bash
hal deploy apply
```

__Note:__ If you're deploying to your local machine, you might need `sudo hal
deploy apply`.


## Connect to the Spinnaker UI

1. Run the following command:

   ```bash
   hal deploy connect
   ```

   If necessary, set up an SSH tunnel to the host running Halyard.

   This  command automatically forwards ports 9000 (Deck UI) and 8084 (Gate API
     service).

1. Navigate to [localhost:9000](localhost:9000).


__Note:__ Even if the `hal deploy apply` command returns successfully, the 
installation may not be complete yet. This is especially the case with 
kubernetes distributed installs. If you see errors such as `Connection refused`
it may be that all of the containers are not yet available. You can either wait, 
or check the status of all of the containers using the commands for your cloud
provider (such as `kubectl get pods --namespace spinnaker`).


### Alternatives

* You can make Spinnaker publicly reachable without running this command,
as described
[here](/setup/quickstart/faq//#i-want-to-expose-localdebian-spinnaker-on-a-public-ip-address-but-it-always-binds-to-localhost)
(for local Debian) and
[here](/setup/quickstart/faq/#i-want-to-expose-the-distributed-kubernetes-hosted-spinnaker-publicly)
(for Kubernetes).

* You can [set up authentication](/setup/security/authentication/).

## Troubleshooting

If this command fails, and it's the first time you've run this command please
reach out to us on [Slack](http://join.spinnaker.io){:target="\_blank"}.
If you've had a successful deployment, you can run `hal deploy diff` to see what
changes you've made that may be causing problems. At any point you can rerun
`hal deploy apply` with any changes you've made to retry the deployment.

## Upgrade Spinnaker

If you want to change Spinnaker versions using Halyard, you can read about
supported versions like so:

```bash
hal version list
```

And pick a new version like so:

```bash
hal config version edit --version $VERSION

# this will update Spinnaker
hal deploy apply
```

## Next steps

Now that Spinnaker is deployed and capable managing your cloud provider, you
can...

* Continue with additional configuration, such as your [image
bakery](/setup/bakery/)

* If you're a Spinnaker end user, read how to [get started using
Spinnaker](/guides/user/get-started)

* Visit the [Guides](/guides/) pages to learn more

You might also want to [back up your configuration](/setup/install/backups/).
