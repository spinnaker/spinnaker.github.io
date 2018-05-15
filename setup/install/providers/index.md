---
layout: single
title:  "__2__. Choose Cloud Providers"
sidebar:
  nav: setup
redirect_from: /docs/target-deployment-setup
redirect_from: /setup/providers/
---

In Spinnaker, *Providers* are integrations to the Cloud platforms you deploy
your applications to.

In this section, you'll register credentials for your Cloud platforms. Those
credentials are known as *Accounts* in Spinnaker, and Spinnaker deploys your
applications via those accounts.

## Supported providers

All of Spinnaker's abstractions and capabilities are built on top of the [Cloud
Providers](/concepts/providers/) that it supports. So, for Spinnaker to do
anything you must enable at least one provider, with one Account added for it.

(In fact, if you use a [Distributed
deployment](/setup/install/environment/#distributed-installation), you'll have
an account (on Kubernetes) to run Spinnaker. You can use that one as your only
provider account, or you can create an additional account for each provider.)


Add as many of the following providers as you need. When you're done, return to this page.

* [App Engine](/setup/install/providers/appengine/)
* [Amazon Web Services](/setup/install/providers/aws/)
* [Amazon Web Services - ECS](/setup/install/providers/ecs/)
* [Azure](/setup/install/providers/azure/)
* [DC/OS](/setup/install/providers/dcos/)
* [Google Compute Engine](/setup/install/providers/gce/)
* [Kubernetes (legacy)](/setup/install/providers/kubernetes/)
* [Kubernetes V2 (manifest based)](/setup/install/providers/kubernetes-v2/)
* [Openstack](/setup/install/providers/openstack/)
* [Oracle](/setup/install/providers/oracle/)

See also [`hal config provider`](/reference/halyard/commands/#hal-config-provider)
for command reference documentation.

## Next steps

When you've finished setting up your cloud provider, you're ready to
[choose an environment](/setup/install/environment/).
