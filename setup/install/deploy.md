---
layout: single
title:  "Deploy"
sidebar:
  nav: setup
redirect_from: /setup/install/upgrades/
---

Now that we've enabled ore or more [Cloud Providers](/setup/providers/), picked
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

If you have not enabled any sort of authentication, Spinnaker will not be
publicly reachable by default. In this case, you will need to run the
following command to reach the UI on [localhost:9000](http://localhost:9000):

```bash
hal deploy connect
```

If you want to make Spinnaker publicly reachable without running that command,
please read the [Halyard FAQ](/setup/quickstart/faq/).

Also, it's likely that you're running Halyard on a separate machine from the
the one running your browser. In this case, you need to set up an SSH tunnel to
forward ports to the host running Halyard.

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
can either visit the [Guides](/guides/) pages to learn how to use Spinnaker, or
continue with additional configuration, such as your [image bakery](/setup/bakery/).

You might also want to [back up your configuration](/setup/install/backups/).
