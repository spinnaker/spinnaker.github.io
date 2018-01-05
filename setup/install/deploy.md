---
layout: single
title:  "Deploy"
sidebar:
  nav: setup
---

Now that we've picked a [Deployment Environment](/setup/install/environment/),
configured [Persistent Storage](/setup/install/storage/), and enabled a [Cloud
Provider](/setup/providers/) we're ready to pick a version of Spinnaker
and deploy it. First, list the available versions:

```bash
hal version list
```

You can follow the links to their changelogs to see what features each version
has included since the last release. Once you've picked a version (e.g.
`VERSION=1.0.0`), you can set it with 

```bash
hal config version edit --version $VERSION
```

And finally, deploy Spinnaker with the following command:

```bash
hal deploy apply
```

__Note:__ If you're deploying to your local machine, that command may need to
be run with `sudo`.

## Connect to the Spinnaker UI

If you have not enabled any sort of authentication, Spinnaker will not be
publically reachable by default. In this case, you will need to run the 
following command to reach the UI on [localhost:9000](http://localhost:9000):

```bash
hal deploy connect
```

If you want to make Spinnaker publically reachable without running that command,
please read the [Halyard FAQ](/setup/quickstart/faq/).

## Troubleshooting

If this command fails, and it's the first time you've run this command please
reach out to us on [Slack](http://join.spinnaker.io). If you've had a successful
deployment, you can run `hal deploy diff` to see what changes you've made that
may be causing problems. At any point you can rerun `hal deploy apply` with any
changes you've made to retry the deployment.

## Next Steps

Now that Spinnaker is deployed and capable managing your cloud provider, you
can either visit the [Guides](/guides/) pages to learn how to use Spinnaker, or
see what other [Configuration](/setup/install/configuration/) is available.
