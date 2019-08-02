---
layout: single
title:  "Overview"
sidebar:
  nav: reference
---

Once you're familar with the definition and setup of a [Cloud
Provider](/setup/providers/), you can read these reference pages for
information on how Spinnaker concepts map to those of the Cloud Provider, as
well as how the various Spinnaker operations are performed at the Cloud
Provider level.

## Supported providers

These are the Cloud Providers currently supported by Spinnaker:

* [App Engine](/reference/providers/appengine/)
* Amazon Web Services
* [Azure](/reference/providers/azure/)
* [Cloud Foundry](/reference/providers/cf)
* [Google Compute Engine](/reference/providers/gce/)
* [Kubernetes](/reference/providers/kubernetes/) (legacy)
* [Kubernetes V2](/reference/providers/kubernetes-v2) (manifest based)
* [Oracle Cloud](/reference/providers/oracle/)

*Note:* The OpenStack provider was supported for a period of time, but after several releases without support [this RFC](https://github.com/spinnaker/spinnaker/issues/4316) concluded with the removal of the provider from Spinnaker. If you are interested in adding this provider back in and supporting it we would be more than happy to help revert the removal.
