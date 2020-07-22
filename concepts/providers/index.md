---
layout: single
title:  "Cloud Providers Overview"
sidebar:
  nav: concepts
---

In Spinnaker, a __Cloud Provider__ is an interface to a set of virtual
resources that Spinnaker has control over. Typically, this is a IaaS provider,
like [AWS](https://aws.amazon.com/), or [GCP](https://cloud.google.com), but it
can also be a PaaS, like [App Engine](https://cloud.google.com/appengine),
or a container orchestrator, like [Kubernetes](https://kubernetes.io).

The cloud provider is central to everything you do in Spinnaker. It's
where you deploy your [Server Groups](/concepts/#server-group), the source of
your deployable artifacts, and the subject of automation via
[Pipelines](/concepts/pipelines).

## Accounts

In Spinnaker, an __Account__ is a named credential Spinnaker uses to
authenticate against a cloud provider. Each provider has slightly different
requirements for what format credentials can be in, and what permissions they
need to have afforded to them. The links under [Supported
Providers](#supported-providers) describe exactly how to create an
account and register the credentials with Halyard.

Keep in mind that every Provider can have as many accounts added as desired -
this will allow you to keep your environments (e.g. _staging_ vs. _prod_)
separate, as well as restrict access to sets of resources using Spinnaker's
[Authorization](/setup/security/authorization) mechanisms.

## Supported providers

These are the cloud providers currently supported by Spinnaker:

* <a href="https://cloud.google.com/appengine/" target="_blank">App Engine</a>
* <a href="https://aws.amazon.com/" target="_blank">Amazon Web Services</a>
* <a href="https://azure.microsoft.com/" target="_blank">Azure</a>
* <a href="https://www.cloudfoundry.org/" target="_blank">Cloud Foundry</a>
* <a href="https://dcos.io/" target="_blank">DC/OS</a>
* <a href="https://docs.docker.com/registry/" target="_blank">Docker v2 Registry</a> (__Note:__ This only
  acts as a source of images, and does not include support for deploying Docker
  images)
* <a href="https://cloud.google.com/compute/" target="_blank">Google Compute Engine</a>
* <a href="https://kubernetes.io/" target="_blank">Kubernetes</a>
* <a href="https://cloud.oracle.com/home" target="_blank">Oracle</a>

Setup instructions for providers are [here](/setup/providers/)

If you see a provider missing from this list that you feel Spinnaker should
support, we gladly welcome your contributions. Please reach out to us on
the __#dev__ channel on [Slack](http://join.spinnaker.io) for help
getting started, and check out the [Contributing
Guide](/community/contributing) for pointers and guidelines.
