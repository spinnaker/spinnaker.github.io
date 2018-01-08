---
layout: single
title:  "Artifacts In Kubernetes (Manifest Based)"
sidebar:
  nav: reference
---

{% include toc %}

Artifacts play an important role in the Kubernetes Provider V2. Everything from
the manifests you deploy, to the Docker images or ConfigMaps they reference
can be expressed or deployed in terms of artifacts.

# Manifests as Artifacts

There are two ways to deploy a manifest - either supplied statically to a
pipeline as text, or as an artifact. The below image demonstrates a deploy
stage that is deploying a manifest stored in a GCS bucket:

{%
  include
  figure
  image_path="./manifest-artifact.png"
  caption="Depending on how this pipeline is configured, it will only run when
  the referenced file in GCS is modified."
%}

# Kubernetes Objects as Artifacts

Once a manifest has been successfully deployed in a pipeline (either from text
or an artifact containing text), it is injected back into the pipeline's
context as an output of the deploy stage. Why this is useful will be explained
below, but for now, focus on the distinction between:

1. An artifact representing manifest stored as text in github:
  ```json
  {
       "type": "github/file",
       "name": "manifests/frontend-configs.yml",
       "reference": "https://api.github.com/repos/your-application/..."
  }
  ```
2. An artifact representing a deployed kubernetes object:
  ```json
  {
       "type": "kubernetes/configMap",
       "name": "frontend-configs",
       "location": "prod",
       "version": "v001"
  }
  ```

As described in the [manifests as artifacts](#manifests-as-artifacts) section,
a deploy stage would consume artifact 1, but produce artifact 2 as an output.

When running pipelines, you can always check the produced outputs for any stage
by examinging the execution's "source" directly:

{%
  include
  figure
  image_path="./check-source.png"
%}

## Versioned Kubernetes Objects

According to the [Kubernetes reference
documentation](/reference/providers/kubernetes-v2/#resource-management-policies),
certain resources are "versioned", meaning that anytime a change is made to an
object's manifest and deployed using Spinnaker, it will be redeployed with a
new version suffix (`-vNNN`). This is critical to supporting immutable
deployments, as rolling out new config maps, secrets, or other versioned
resources should require any manifests that reference them to be updated as
well. Luckily, Spinnaker makes handling these updates easy as explained
[below](#consuming-artifacts-in-manifests).

# Consuming Artifacts in Manifests

Generally, artifacts represent resources that you update as a part of your
deployment/delivery piplines. Given that Docker images and ConfigMaps are what
will likely be updated within a manifest, we provide easy, first-class ways of
injecting them into your manifests. If you're familiar with [Pipeline
Expressions](/guides/user/pipeline-expressions) and are curious why we don't
just rely on those, read [why not pipeline
expressions](#why-not-pipeline-expressions) below.

Spinnaker will replace fields in your manifest based on a simple heuristic:

  _When a field's referenced type and value match an incoming artifact's type
  and name, the field's value is replaced with the artifact's reference_

A "field's referenced type" sounds ambiguous, but in practice, it is
straightforward. The field `spec.template.spec.containers.*.image` will always
refer to a Docker image, so clearly it matches the artifact type
`docker/image`. The field `spec.template.spec.volumes.*.configMap.name` will
always refer to a ConfigMap, so it clearly matches the artifact type
`kubernetes/configMap`. The same logic applies throughout.

Let's go through an example to make this clear:

We have the following manifest to be deployed in a Spinnaker pipeline:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: gcr.io/my-images/nginx # possible artifact
          name: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - mountPath: /opt/config
              name: my-config-map
      volumes:
        - configMap:
            name: configmap             # possible artifact
          name: my-config-map 
```

And when the deploy stage executes, we have the following artifacts in our
execution context (likely populated from a trigger event, or prior deployments):

```json
[
  { 
    "type": "docker/image",
    "name": "gcr.io/my-images/nginx",
    "reference": "gcr.io/my-images/nginx@sha256:0cce25b9a55"
  }, 
  { 
    "type": "kubernetes/configMap",
    "name": "configmap",
    "version": "v001",
    "location": "default",
    "reference": "configmap-v001"
  }
]
```

The ConfigMap and Docker image are replaced by the artifacts in the context,
and the resulting manifest is deployed into your cluster:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: gcr.io/my-images/nginx@sha256:0cce25b9a55    # replaced by spinnaker
          name: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - mountPath: /opt/config
              name: my-config-map
      volumes:
        - configMap:
            name: configmap-v001                              # replaced by spinnaker
          name: my-config-map 
```

## Why Not Pipeline Expressions?

[Pipeline Expressions](/guides/user/pipeline-expressions) offer a great way of
referencing pipeline context programatically using short snippets of code. Of
course, it's possible to construct expressions that would allow you to
reference the Docker image's reference that triggered a pipeline, or the name
of the ConfigMap you deployed in a prior stage. However, we wanted an easier
way to express updates to these resources, that left your Kubernetes Manifests
natively deployable without making Spinnaker's expression engine a hard
dependency.
