---
layout: single
title:  "Configuration"
sidebar:
  nav: setup
---

{% include toc %}

There are a number of other things you can configure in your Spinnaker
installation enumerated below. At any point in time, assuming that your
configuration changes were accepted by Halyard (no validation failed), you can
apply your configuration using the same command used to initially provision
Spinnaker:

```bash
hal deploy apply
```

### Deploy to More Environments

[Documentation](/setup/providers/) -- `hal config provider`

You can add more Accounts to as many Providers as you want. There is nothing
preventing you from deploying to two Kubernetes clusters, one Google Compute
Engine project, and an App Engine application all at once.

### Edit Your Storage Settings

[Documentation](/setup/storage/) -- `hal config storage`

While you have likely already setup a storage source during the initial
installation of Spinnaker, you can always reconfigure it. However, it is up to
you to migrate any data that you depend on.

### Secure Your Spinnaker Installation

[Documentation](/setup/security/) -- `hal config security`

You can configure SSL, setup a login page, or apply role-based authorization.

### Setup Continuous Integration

[Documentation](/setup/ci/) -- `hal config ci`

Configure Jenkins or Travis CI to trigger Pipelines or supply Spinnaker with
build artifacts to build into images and deploy.

### Configure Notifications

[Documentation](/setup/features/notifications/) -- ` `

Enable notifications to be sent on Spinnaker events, and allow external events
to trigger Pipelines in Spinnaker.

### Monitor Your Spinnaker Installation

[Documentation](/setup/monitoring/) -- `hal config metric-stores`

Publish timeseries data from your Spinnaker installation to a variety of
metric sources into curated dashboards. This is useful for understanding how
to scale and troubleshoot your deployment of Spinnaker.

## Next Steps

Now that you know how to make configuration changes, it's worth learning how to
[Upgrade Spinnaker](/setup/install/upgrades/).
