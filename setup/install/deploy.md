---
layout: single
title:  "Deploy"
sidebar:
  nav: setup
---

{% include toc %}

Now that we've picked a [Deployment Environment](/setup/install/environment) as
well as configured [Persistent Storage](/setup/install/storage), we're ready to
deploy Spinnaker with the following command:

```
hal deploy apply
```

__Note:__ If you're deploying to your local machine, that command may need to
be run with `sudo`.

## Troubleshooting

If this command fails, and it's the first time you've run this command please
reach out to us on [Slack](join.spinnaker.io). If you've had a successful
deployment, you can run `hal deploy diff` to see what changes you've made that
may be causing problems. At any point you can rerun `hal deploy apply` with any
changes you've made to retry the deployment.

## Next Steps

So far we have a very minimal, but functional installation of Spinnaker. If you
want to add more accounts to manage, configure authentication, add
monitoring, enable external CI integrations and more, head over to [Configuring
Spinnaker](/setup/install/configuration).
