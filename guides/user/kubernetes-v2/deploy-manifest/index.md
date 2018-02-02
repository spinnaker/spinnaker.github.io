---
layout: single
title:  "Deploy Kubernetes Manifests"
sidebar:
  nav: guides
---

{% include toc %}

This guide is meant to show you the very basics of how to deploy a Kubernetes
Manifest using Spinnaker, using the [Kubernetes Provider
V2](/setup/install/providers/kubernetes-v2).

There are two things to cover here:

* [How to specify which manifest to deploy](#specifying-your-manifest)
* [How to override artifacts in the manifest](#overriding-artifacts)

At a high level, you specify a manifest to deploy, and optionally, can override
certain artifacts (as fields) at runtime (e.g. the docker image to use).

## Specifying Your Manifest

Depending on your needs, there is more than one way to specify the manifest
that you want to deploy:

* [Statically: directly in the pipeline](#specifying-manifests-statically)
* [Dynamically: bound at runtime using an
  artifact](#specifying-manifests-dynamically)

In either case, we want to start by selecting the __Deploy (Manifest)__ stage
from the stage selector as shown here:

{%
  include
  figure
  image_path="./deploy-manifest.png"
%}

> :warning: Don't select the regular __Deploy__ stage, it is used to deploy more 
> opinionated "Server Groups" using another provider (including Kubernetes V1).

### Specifying Manifests Statically

If you know ahead of time what you expect to deploy using a certain manifest
(even if you don't know what version of your docker image it will run) you can
declare it directly in the pipeline by providing the manifest specification.

{%
  include
  figure
  image_path="./in-pipeline.png"
  caption="Notice that by selecting \"Text\" as the __Manifest Source__, we get
  to enter the Manifest YAML by hand."
%}

Of course, if you are generating your pipeline definitions rather than entering
them into the UI, the stage definition would look more like:

```json
{
  "name": "Deploy my manifest",   // human-readable name
  "type": "deployManifest",       // tells orchestration engine what to run
  "account": "nudge",             // account (k8s cluster) to deploy to
  "cloudProvider": "kubernetes",
  "source": "text",
  "manifest": {
                                  // manifest contents go here
  },
  "moniker": {                    // specifies app & cluster for grouping
                                  // resources in UI
    "app": "xnat",
    "cluster": "c7",
  }
}
```

### Specifying Manifests Dynamically 

If you are storing your manifests outside of Spinnaker's pipeline repository,
or want a single deploy stage to be able to deploy a variety of manifests, you
can specify your manifest using an [Artifact](/reference/artifacts).

The idea is: artifacts in Spinnaker allow you to reference remote, deployable
resources. When using the Deploy Manifest stage, artifacts will reference a
text file (containing a Manifest specification). This can be stored in GitHub
or an object store (like GCS).

For more information about triggering based on changes:

* [Consuming GitHub Artifacts](/guides/user/triggers/github)
* [Consuming GCS Artifacts](/guides/user/triggers/gcs)

Assuming you have declared an expected artifact upstream to your Deploy
manifest stage, you can reference it in the Deploy configuration:

{%
  include
  figure
  image_path="./in-artifact.png"
  caption="Notice that by selecting \"Artifact\" as the __Manifest Source__, we
  get to pick which upstream artifact to deploy."
%}

> __☞ Note__: Make sure that the __Artifact Account__ field matches an artifact 
> with permission to download your manifest.

Keep in mind that the artifact bound in the upstream stage can match multiple
incoming artifacts. If instead we had configured it to listen to changes using
a regex matching `.*\.yml`, it would bind any YAML file that changes in your
artifact source, and deploy it when it reaches your Deploy stage.

## Overriding Artifacts

In general, when we deploy changes to our infrastructure, the majority of
changes will come in the form of a new Docker image, or perhaps a feature-flag
change in a ConfigMap. For this reason, we have first-class mechanisms for
easily overriding the version of:

* Docker Image
* Kubernetes ConfigMap
* Kubernetes Secret

When one of these objects exists in the pipeline context from an upstream
stage, Spinnaker will automatically try to inject it into the manifest you're
deploying. A description of how this works can be read
[here](/reference/artifacts/in-kubernetes-v2/#binding-artifacts-in-manifests)
in detail.

To give a quick example, say you trigger your pipeline using a webhook coming
from a Docker registry. At a high level, the event says "Image
`gcr.io/my-project/my-image` has a new digest `sha256:c81e41ef5e...`". In the
pipeline that gets triggered, you've configured a Deploy Manifest stage with
the following spec:

```yaml
# ... rest of manifest
  containers:
  - name: my-container
    image: gcr.io/my-project/my-image
# rest of manifest ...
```

Since the pipeline was triggered by the Docker image changing, the
orchestration engine will send that artifact along with the manifest to the
Spinnaker's cloud provider integration service, which, based on the name of the
Docker image, will deploy the following:

```yaml
# ... rest of manifest
  containers:
  - name: my-container
    image: gcr.io/my-project/my-image@:sha256:c81e41ef5e...
# rest of manifest ...
```

In order to help ensure that the correct artifacts get bound, you can force the
stage to either bind all required artifacts, or fail before deploying. Take the
below image for example, where we specify that the docker image
`gcr.io/my-project/my-image` must be bound in the manifest, otherwise the stage
will fail:

{%
  include
  figure
  image_path="./required-artifacts.png"
  caption="Keep in mind that even if you don't specify an artifact as required,
  it can still be bound in the manifest. This is just to ensure that all
  artifacts you expect will be bound."
%}
