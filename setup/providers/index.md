---
layout: single
title:  "Overview"
sidebar:
  nav: setup
---

{% include toc %}

In Spinnaker, a __Cloud Provider__ is an interface to a set of virtual 
resources that Spinnaker has control over. Typically, this is a IaaS provider, 
like [AWS](https://aws.amazon.com/), or [GCP](https://cloud.google.com), but it 
can also be a PaaS, like [App Engine](https://cloud.google.com/appengine), 
or a container orchestrator, like [Kubernetes](https://kubernetes.io). 

The cloud provider is central to everything you do in Spinnaker. It will be
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

## Supported Providers

These are the cloud providers currently supported by Spinnaker:

* [App Engine](/setup/providers/appengine)
* [Amazon Web Services](/setup/providers/aws)
* [Azure](/setup/providers/azure)
* [Docker v2 Registry](/setup/providers/docker-registry) (__Note:__ This only 
  acts as a source of images, and does not include support for deploying Docker
  images)
* [Google Compute Engine](/setup/providers/gce)
* [Kubernetes](/setup/providers/kubernetes)
* [Openstack](/setup/providers/openstack)
* [Oracle](/setup/providers/oracle)
* [Titus](/setup/providers/titus)

If you see a provider missing from that list that you feel Spinnaker should
support, we will gladly welcome your contributions. Please reach out to us on
the __#dev__ channel on [Slack](http://join.spinnaker.io) for help
getting started, and check out the [Contributing 
Guide](/community/contributing) for pointers and guidelines.
