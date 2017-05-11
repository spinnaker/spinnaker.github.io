---
layout: single
title:  "Deploy"
sidebar:
  nav: setup
---

{% include toc %}

Now that we've picked a [Deployment Environment](/setup/install/environment/),
configured [Persistent Storage](/setup/install/storage/), and enabled a [Cloud
Provider](/setup/install/providers/) we're ready to
deploy Spinnaker with the following command:

```
hal deploy apply
```

__Note:__ If you're deploying to your local machine, that command may need to
be run with `sudo`.

## Troubleshooting

If this command fails, and it's the first time you've run this command please
reach out to us on [Slack](http://join.spinnaker.io). If you've had a successful
deployment, you can run `hal deploy diff` to see what changes you've made that
may be causing problems. At any point you can rerun `hal deploy apply` with any
changes you've made to retry the deployment.

## Next Steps

Now that Spinnaker is deployed and capable managing your cloud provider, you
can either visit the [Guides](/guides) pages to learn how to use Spinnaker, or
see what other [Configuration](/setup/install/configuration/) is available.
