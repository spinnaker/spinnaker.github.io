---
layout: single
title:  "Cloud Providers"
sidebar:
  nav: setup
redirect_from: /docs/target-deployment-setup
redirect_from: /setup/providers/
---

In Spinnaker, *Providers* are integrations to the Cloud platforms your
applications deploy to and run on. In this section, you'll be registering
credentials for your Cloud platforms, known as *Accounts* in Spinnaker, by
which Spinnaker deploys your applications to them.

## Supported providers

All of Spinnaker's abstractions and capabilities are built on top of the [Cloud
Providers](/concepts/providers/) that it supports. So, for Spinnaker to be able to do anything you
need to have at least one enabled, configured as an Account.

Add as many as you need/like. When you're done, return to this page.

* <a href="/setup/install/providers/appengine/">App Engine</a>
* <a href="/setup/install/providers/aws/">Amazon Web Services</a>
* <a href="/setup/install/providers/ecs/">Amazon Web Services - ECS</a>
* <a href="/setup/install/providers/azure/">Azure</a>
* <a href="/setup/install/providers/dcos/">DC/OS</a>
* <a href="/setup/install/providers/gce/">Google Compute Engine</a>
* <a href="/setup/install/providers/kubernetes/">Kubernetes (legacy)</a>
* <a href="/setup/install/providers/kubernetes-v2/">Kubernetes V2 (manifest based)</a>
* <a href="/setup/install/providers/openstack/">Openstack</a>
* <a href="/setup/install/providers/oracle/">Oracle</a>

See also [`hal config provider`](/reference/halyard/commands/#hal-config-provider).

## Next steps

When you've finished setting up your cloud provider, you're ready to [Deploy Spinnaker](/setup/install/deploy/).
