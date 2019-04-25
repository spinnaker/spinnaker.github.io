---
layout: single
title:  "Deploy Kubernetes Manifests"
sidebar:
  nav: guides
---

{% include toc %}

This guide shows the basics of how to deploy a Kubernetes manifest using the
[Kubernetes Provider V2](/setup/install/providers/kubernetes-v2).

There are two main steps:

* [Specify which manifest to deploy](#specify-your-manifest)

  This is required.

* [Override artifacts in the manifest](#override-artifacts)

  Optionally, you can override some artifacts (as fields) at run time (for
    example, which Docker image to use.)

## Specify your manifest

Depending on your needs, there is more than one way to specify the manifest
that you want to deploy:

* [Statically: directly in the pipeline](#specify-manifests-statically)
* [Dynamically: bound at runtime using an artifact](#specify-manifests-dynamically)

In either case, start by selecting the __Deploy (Manifest)__ stage
from the stage selector:

{%
  include
  figure
  image_path="./deploy-manifest.png"
%}

> :warning: Don't select the regular __Deploy__ stage; it deploys more
> opinionated "Server Groups" using another provider (including Kubernetes V1).

### Specify manifests statically

If you know ahead of time what you expect to deploy using a certain manifest
(even if you don't know what version of your Docker image it will run) you can
declare it directly in the pipeline by providing the manifest specification:

{%
  include
  figure
  image_path="./in-pipeline.png"
  caption="Notice that by selecting __Text__ as the __Manifest Source__, we get
  to enter the manifest YAML by hand."
%}

Of course, if you are _generating_ your pipeline definitions rather than entering
them into the UI, the stage definition would look more like this:

```json
{
  "name": "Deploy my manifest",   // human-readable name
  "type": "deployManifest",       // tells orchestration engine what to run
  "account": "nudge",             // account (k8s cluster) to deploy to
  "cloudProvider": "kubernetes",
  "source": "text",
  "manifest": {
                                  // manifest contents go here
  }
}
```

### Specify manifests dynamically

If you are storing your manifests outside of Spinnaker's
[pipeline repository](/setup/install/storage/),
or want a single deploy stage to deploy a variety of manifests, you
can specify your manifest using an [Artifact](/reference/artifacts).

The idea is: artifacts in Spinnaker allow you to reference remote, deployable
resources. When referencing an artifact from a Deploy Manifest stage , that
artifact must be a text file containing the Manifest specification.
This can be stored in GitHub or an object store (like GCS).

Changes to manifests can trigger pipelines. Here's some more information:

* [Consuming GitHub Artifacts](/guides/user/triggers/github)
* [Consuming GCS Artifacts](/guides/user/triggers/gcs)

Assuming you have declared an expected artifact upstream to your Deploy
manifest stage, you can reference it in the Deploy configuration:

{%
  include
  figure
  image_path="./in-artifact.png"
  caption="Notice that by selecting __Artifact__ as the __Manifest Source__, we
  get to pick which upstream artifact to deploy."
%}

> __☞ Note__: Make sure that the __Artifact Account__ field matches an account
> with permission to download the manifest.

Keep in mind that the artifact bound in the upstream stage can match multiple
incoming artifacts. If instead we had configured it to listen to changes using
a regex matching `.*\.yml`, it would bind any YAML file that changes in your
artifact source, and deploy it when it reaches your Deploy stage.

## Override artifacts

In general, when we deploy changes to our infrastructure, the majority of
changes come in the form of a new Docker image, or perhaps a feature-flag
change in a ConfigMap. For this reason, we have first-class mechanisms for
easily overriding the version of...

* Docker image
* Kubernetes ConfigMap
* Kubernetes Secret

When one of these objects exists in the pipeline context from an upstream stage,
Spinnaker [automatically tries to inject it](/reference/artifacts/in-kubernetes-v2/#binding-artifacts-in-manifests)
into the manifest you're deploying.

For example, say you trigger your pipeline using a webhook coming
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

Because the pipeline was triggered by a change to the Docker image, the
orchestration engine send that artifact along with the manifest to
Spinnaker's cloud provider integration service, which, based on the name of the
Docker image, deploys the following:

```yaml
# ... rest of manifest
  containers:
  - name: my-container
    image: gcr.io/my-project/my-image@:sha256:c81e41ef5e...
# rest of manifest ...
```

To ensure that the correct artifacts get bound, you can force the
stage to either bind all required artifacts, or fail before deploying. Here's an
example where we specify that the docker image
`gcr.io/my-project/my-image` must be bound in the manifest, otherwise the stage
fails:

{%
  include
  figure
  image_path="./required-artifacts.png"
  caption="Keep in mind that even if you don't specify an artifact as required,
  it can still be bound in the manifest. This is just to ensure that all
  artifacts you expect will be bound."
%}
