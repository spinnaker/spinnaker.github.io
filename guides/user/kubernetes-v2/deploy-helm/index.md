---
layout: single
title:  "Deploy Helm Charts"
sidebar:
  nav: guides
---

{% include toc %}

Spinnaker surfaces a "Bake (Manifest)" stage to turn templates into manifests
with the help of a templating engine. Currently, the only supported templating
engine is [Helm](https://helm.sh/), by relying on the `helm template` command.
See more details [here](https://helm.sh/docs/helm/#helm-template).

> Note: This stage is intended to help you package and deploy applications
> that you own, and are actively developing and redeploying frequently.
> It is not intended to serve as a one-time installation method for
> third-party packages. If that is your goal, it's arguably better to call
> [`helm install`](https://helm.sh/docs/helm/#helm-install) once when
> bootstrapping your Kubernetes cluster.

> Note: Make sure that you have configured [artifact support](/setup/artifacts)
> in Spinnaker first. All Helm charts are fetched/stored as artifacts in
> Spinnaker. Read more in the [reference pages](/reference/artifacts).

## Configure the "Bake (Manifest)" stage

When configuring the "Bake (Manifest)" stage, you can specify the following:

* __The release name__ (required)

  The Helm release name for this chart. This determines the name of the
  artifact produced by this stage.

> Note: this name will override any changes you make to the name
> in the Produces Artifacts section.

* __The template artifact__ (required)

  The Helm chart that you will be deploying, stored remotely as a
  `.tar.gz` archive. You can produce this by running `helm package
  /path/to/chart`. See more details
  [here](https://helm.sh/docs/helm/#helm-package).

* __The release namespace__ (optional)

  The Kubernetes namespace to install release into. If parameter is not
  specified default namespace will be used.

> Note: Not all Helm charts contain namespace definitions in their manifests.
> Make sure that your manifests contain the following code:

{% raw %}
```yaml
metadata:
  namespace: {{ .Release.Namespace }}
```
{% endraw %}

* __Zero or more override artifacts__ (optional)

  The files passed to `--values` parameter in the [`helm
  template` command](https://helm.sh/docs/helm/#helm-template). Each is a
  remotely stored artifact representing a [Helm Value
  File](https://helm.sh/docs/chart_template_guide/#values-files).

* __Statically specified overrides__

  The set of static of key/value pairs that are passed as `--set` parameters to
  the [`helm template` command](https://helm.sh/docs/helm/#helm-template).

As an example, we have a fully configured Bake (Manifest) stage below:

{%
  include
  figure
  image_path="./bake-manifest-stage.png"
%}

Notice that in the "Produces Artifacts" section, Spinnaker has automatically
created an `embedded/base64` artifact that is bound when the stage
completes, representing the fully baked manifest set to be deployed downstream.

{%
  include
  figure
  image_path="./produces.png"
%}

If you are programatically generating stages, here is the JSON representation
of the same stage from above:

```json
{
  "type": "bakeManifest",
  "templateRenderer": "HELM2",
  "name": "Bake nginx helm template",
  "outputName": "nginx",
  "inputArtifacts": [
    {
      "account": "gcs",
      "id": "template-id"
    },
    {
      "account": "gcs",
      "id": "value-id"
    }
  ],
  "overrides": {
    "replicas": "3"
  },
  "expectedArtifacts": [
    {
      "defaultArtifact": {},
      "id": "baked-template",
      "matchArtifact": {
        "kind": "base64",
        "name": "nginx",
        "type": "embedded/base64"
      },
      "useDefaultArtifact": false
    }
  ]
}
```

## Configure a downstream deployment

Now that your manifest set has been baked by Helm, configure a downstream stage
(in the same pipeline or in one triggered by this pipeline) your "Deploy
(Manifest)" stage to deploy the artifact produced by the "Bake (Manifest)"
stage as shown here:

{%
  include
  figure
  image_path="./expected-artifact.png"
%}

> Note: Make sure to select "embedded-artifact" as the artifact account for
> your base64 manifest set. This is required to translate the manifest set into
> the format required by the deploy stage.

When this stage runs, you can see every resource in your Helm chart get
deployed at once:

{%
  include
  figure
  image_path="./result.png"
%}
