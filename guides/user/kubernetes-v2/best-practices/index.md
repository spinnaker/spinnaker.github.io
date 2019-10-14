---
layout: single
title:  "Best Practices for the Kubernetes Provider V2"
sidebar:
  nav: guides
---

{% include toc %}

The Kubernetes Provider V2 enables a wide variety of ways to deploy your
manifests into Kubernetes clusters. This page provides best-practices for doing
so.

## Deploy Docker images by digest

If your registry exposes image changes by
[digest](https://docs.docker.com/registry/spec/api/#content-digests), we
recommend deploying images by their digest rather than tag, e.g.
`gcr.io/my-image@sha256:95ff090...` rather than `gcr.io/my-image:v1`.

The digest is a content-addressable way to reference
your image, because it's derived from the hash of the image contents. If your
manifest points to an image by its digest, you know that each time it's
deployed it points to the same contents (binary, dependencies, config,
etc...). If you rely on the tag, deploying the same
Manifest twice can have different results.

There are two ways to achieve this in Spinnaker:

1. Templatize your manifests outside of Spinnaker to point to the digest you want
   to deploy. This means using some
   templating language ([jsonnet](http://jsonnet.org/),
   [jinja](http://jinja.pocoo.org/)) to express & render your manifests
   _before_ sending them to Spinnaker to deploy.

2. Rely on Spinnaker's [artifact substitution](/guides/user/kubernetes-v2/deploy-manifest/#override-artifacts)
   and a trigger that supplies your image by digest.

## Emit your deployed manifests to an audit log

To keep track of what's changing in your cluster, and under what circumstances
it is changing, we highly recommend [configuring Spinnaker to emit events to an
external audit
log](https://blog.spinnaker.io/spinnaker-echo-google-cloud-functions-stackdriver-logging-spinnaker-audit-log-81139f084db9).

Spinnaker already generates events for any events running through its
orchestration engine, all that's needed is an endpoint to send them to.  When
set up, any pipeline that deploys or updates a manifest will have your fully
hydrated manifest recorded.

## Version your ConfigMaps and Secrets

Anytime Spinnaker deploys a ConfigMap or Secret, it appends a version to
its name. If that exact ConfigMap or secret is already running in the cluster,
it's not redeployed. Downstream stages that reference the ConfigMap or
secret will deploy the version chosen by Spinnaker. __Unless your application
requires hot-reloading of configuration, this is essential for practicing
safe delivery__.

Let's go through two examples:

### You want to slowly roll out a configuration change

Say you are rolling out a new feature, hidden behind a feature-flag. All
that's needed is an update to a ConfigMap referenced by a Deployment.

If your Deployment has mounted this ConfigMap, pushing a change to it
immediately allows all Pods to read the update, rendering any sort of rollout
useless. This happens even if the Deployment rolls out another
configuration change using the typical Rolling Update policy.

If instead you push a new ConfigMap, and edit the Deployment to
reflect this change, only the newly deployed Pods will have your feature flag
enabled.

### You need to roll back a broken configuration change

With an unversioned ConfigMap, the "Rollback" feature on Deployments,
StatefulSets, and DaemonSets does not have the desired effect, because a material
change to a ConfigMap referenced by a Pod in these controllers does not show up
in your PodSpec, only the ConfigMap's `data` section. In this case, the
only option is to "Roll forward" by pushing an update to your ConfigMap, and
any (potentially related) changes to controllers depending on your ConfigMap.
However, this approach can have a few problems:

* Every Pod reading that ConfigMap is rolled forward to the old
  configuration at once, even ones belonging to controllers that aren't
  necessarily broken.

* If the broken controller was rolled out with a dependent binary change,
  rolling forward the config at the same time can exacerbate the problem in the
  current broken controller until the rollout completes.

## Avoid using the ad-hoc "edit" features when possible

Spinnaker provides quick ways to edit your deployed Manifests in the
infrastructure screen. This is done to provide you a quick fallback when
mitigating a broken rollout, or to increase the number of pods serving traffic.

{%
  include
  figure
  image_path="./edit.png"
%}

However, as long as your manifests are stored either in an external store, or
in Spinnaker pipelines, these edits are overwritten the next time you deploy
your manifests. For this reason, any edits that can be made in your stored
manifests should be made there and redeployed.
