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

todo(lwander) https://github.com/spinnaker/halyard/issues/311

## Next Steps

So far we have a very minimal, but functional installation of Spinnaker. If you
want to add more accounts to manage, configure authentication, add
monitoring, enable external CI integrations and more, head over to [Configuring
Spinnaker](/setup/install/configuration).
