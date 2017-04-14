---
layout: single
title:  "Overview"
sidebar:
  nav: setup
---

{% include toc %}

For Spinnaker, a cloud provider is an interface to a set of virtual resources 
that Spinnaker has control over. Typically, this is a IaaS provider, like
[AWS](https://aws.amazon.com/), or [GCP](https://cloud.google.com), but it can
also be a PaaS, like [App Engine](https://cloud.google.com/appengine), 
or a container orchestrator, like [Kubernetes](https://kubernetes.io). 

The cloud provider is central to everything you do in Spinnaker. It will be
where you deploy your [Server Groups](/concepts#server-groups), the source of
your deployable artifacts, and the subject of automation via
[Pipelines](/concepts/pipelines).

## Supported Providers

These are the cloud providers currently supported by Spinnaker:

* [App Engine](/setup/providers/appengine)
* [Amazon Web Services](/setup/providers/aws)
* [Azure](/setup/providers/azure)
* [Docker v2 Registry](/setup/providers/docker-registry) __Note:__ This is
  only acts as a source of images, and does not include support for Docker Swarm.
* [Google Compute Engine](/setup/providers/gce)
* [Kubernetes](/setup/providers/kubernetes)
* [Openstack](/setup/providers/openstack)
* [Oracle](/setup/providers/oracle)
* [Titus](/setup/providers/titus)
