---
layout: single
title:  "Cloud Providers"
sidebar:
  nav: setup
redirect_from: /docs/target-deployment-setup
redirect_from: /setup/providers/
---

All of Spinnaker's abstractions and capabilities are built on top of the [Cloud
Providers](/concepts/providers/) that it supports. So, for Spinnaker to be able to do anything you
need to have at least one enabled, with one Account added. If you've picked the
[Distributed](/setup/install/environment/#distributed) deployment you have
already done this step, so unless you want to deploy to multiple Providers, you
can skip this.

## Supported Providers

These are the cloud providers currently supported by Spinnaker. Click through for instructions for setting up each provider.

* <a href="/setup/install/providers/appengine/">App Engine</a>
* <a href="/setup/install/providers/aws/">Amazon Web Services</a>
* <a href="/setup/install/providers/azure/">Azure</a>
* <a href="/setup/install/providers/dcos/">DC/OS</a>
* <a href="/setup/install/providers/gce/">Google Compute Engine</a>
* <a href="/setup/install/providers/kubernetes/">Kubernetes (legacy)</a>
* <a href="/setup/install/providers/kubernetes-v2/">Kubernetes V2 (manifest based)</a>
* <a href="/setup/install/providers/openstack/">Openstack</a>
* <a href="/setup/install/providers/oracle/">Oracle</a>

See also [`hal config provider`](/reference/halyard/commands/#hal-config-provider).

## Next Steps

When you've finished setting up your cloud provider, you're ready to [Deploy Spinnaker](/setup/install/deploy/).
