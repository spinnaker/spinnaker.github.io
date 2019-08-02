---
layout: single
title:  "Patch Kubernetes Manifests"
sidebar:
  nav: guides
---

{% include toc %}

This guide shows the basics of how to update a Kubernetes resource in place using the patch manifest stage for the [Kubernetes Provider V2](/setup/install/providers/kubernetes-v2) provider.

There are a few steps:

* [Specify which manifest to patch](#specify-the-resource-to-patch)

* [Specify the patch content](#specify-your-patch-content)

* [(Optional) Override artifacts in the patch content](#override-artifacts)

  Optionally, you can override some artifacts (as fields) at run time (for
    example, which Docker image to use.)

* [(Optional) Override patch specific options](#specify-patch-options)

## Specify the resource to patch

1. Start by selecting the __Patch (Manifest)__ stage from the stage selector:

{%
  include
  figure
  image_path="./patch-manifest.png"
%}

2. To identify the Kubernetes resource to patch, specify the following required fields:

* __Account__

  The Spinnaker account that manages the Kubernetes cluster

* __Namespace__

  The Kubernetes namespace that your resource is located in

* __Kind__

  The Kubernetes Kind of your resource e.g. deployment, service etc

* __Name__

  The name of your Kubernetes resource


## Specify your patch content

The patch content is similar to a manifest in the Deploy (Manifest) stage. However, unlike the deploy manifest, this does not have to be the full resource manifest but only the portion you want to patch.

Depending on your needs, there is more than one way to specify the patch content:

* [Statically: directly in the pipeline](#specify-patch-content-statically)
* [Dynamically: bound at runtime using an artifact](#specify-patch-content-dynamically)


### Specify patch content statically

You can enter the patch content YAML by hand. For instance, if you want to patch your manifest to add a new label, you will specify the following:

```yaml
metadata:
  labels:
    foo: bar
```

{%
  include
  figure
  image_path="./in-pipeline.png"
  caption="Notice that by selecting __Text__ as the __Manifest Source__, we get
  to enter the manifest YAML by hand."
%}

### Specify patch content dynamically

Like the [Deploy (Manifest) stage](/guides/user/kubernetes-v2/deploy-manifest#specify-manifests-dynamically), you can also reference an artifact as the source if you are storing your patch content externally. The artifact must be a text file containing the patch content.

You can also set up the pipeline to trigger based on changes to the patch content:

* [Consuming GitHub Artifacts](/guides/user/triggers/github)
* [Consuming GCS Artifacts](/guides/user/triggers/gcs)

Assuming you have declared an expected artifact upstream to your Patch (Manifest) stage, you can reference it in the Patch configuration:

{%
  include
  figure
  image_path="./in-artifact.png"
  caption="Notice that by selecting __Artifact__ as the __Manifest Source__, we
  get to pick which upstream artifact to deploy."
%}

> __☞ Note__: Make sure that the __Artifact Account__ field matches an account
> with permission to download the manifest.


## Override artifacts

When patching with a _strategic_ or _merge_ strategy, the Patch (Manifest) stage also allows you to [override artifacts](/guides/user/kubernetes-v2/deploy-manifest#override-artifacts) like in the deploy manifest stage.

For instance, say you have a pipeline with a Patch (Manifest) stage with the following patch content:

```yaml
spec:
  template:
    spec:
      containers:
        - name: my-container
          image: gcr.io/my-project/my-image
```

Now, if your pipeline was triggered due to a new Docker image tag being pushed to your Docker registry (say my-image:2.0), Spinnaker will override the version of the container image with the new version:

```yaml
#...rest of manifest
containers:
  - name: my-container
    image: gcr.io/my-project/my-image:2.0
```
For more information on how this works, check out the [binding artifacts docs](/reference/artifacts/in-kubernetes-v2#binding-artifacts-in-manifests).


## Specify Patch Options

You can also specify the following options:

* __Record Patch Annotation__

  Defaults to true. When selected, the patch operation including the patch content will be recorded on the patched resource as the `kubernetes.io/change-cause` annotation. If the annotation already exists, the contents are replaced.


* __Merge Strategy__

  * _strategic_: This is the default. It is a [customized version of JSON merge patch](https://github.com/kubernetes/community/blob/master/contributors/devel/strategic-merge-patch.md) specific to Kubernetes that allows Kubernetes objects to be either replaced or merged based on the object struct tags. It is particularly useful when you want to add a new item to a list (e.g. a new annotation, label, or even a new container to a pod spec) instead of replacing the list.

  * _json_: This will patch the manifest using a standard [RFC 6902 JSON patch](https://tools.ietf.org/html/rfc6902).

  * _merge_: This will patch the manifest using [RFC 7386 JSON Merge Patch](https://tools.ietf.org/html/rfc7386).
