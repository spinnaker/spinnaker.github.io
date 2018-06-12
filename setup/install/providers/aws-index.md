---
layout: single
title:  "__2__. Amazon Web Services"
sidebar:
  nav: setup
redirect_from: /docs/target-deployment-setup
redirect_from: /setup/providers/
---

{% include toc %}

In Spinnaker, *Providers* are integrations to the Cloud platforms you deploy
your applications to.

In this section, you'll register credentials for your Cloud platforms. Those
credentials are known as *Accounts* in Spinnaker, and Spinnaker deploys your
applications via those accounts.

## Supported providers

All of Spinnaker's abstractions and capabilities are built on top of the [Cloud
Providers](/concepts/providers/) that it supports. So, for Spinnaker to do
anything you must enable at least one provider, with one Account added for it.

Add as many of the following providers as you need. When you're done, return to this page.

* [Amazon Web Services - Console](/setup/install/providers/aws/aws-console/)
* [Amazon Web Services - CLI](/setup/install/providers/aws/aws-cli/)

See also [`hal config provider`](/reference/halyard/commands/#hal-config-provider)
for command reference documentation.

## Next steps

When you've finished setting up your cloud provider, you're ready to
[choose an environment](/setup/install/environment/).
