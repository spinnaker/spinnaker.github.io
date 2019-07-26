---
layout: single
title:  "Kubernetes Object"
sidebar:
  nav: reference
---

{% include toc %}

Kubernetes Object artifacts are _running_, _deployed_ Kubernetes manifests.
This is in contrast to something like a GitHub file that only contains the
specification of a deployable Kubernetes manifest.

## Kubernetes Object Artifact in the UI

The pipeline UI exposes the following fields for the Kubernetes object artifact:

<table>
  <thead>
    <tr>
      <th>Field</th>
      <th>Explanation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Account</strong></td>
      <td>An HTTP artifact account.</td>
    </tr>
    <tr>
      <td><strong>URL</strong></td>
      <td>The fully-qualified URL from which the file can be read.</td>
    </tr>
  </tbody>
</table>

### In a Trigger

When configuring certain triggers, you can use a Kubernetes object as an
expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-kubernetes-object.png"
  caption="Configuring Kubernetes object fields in a pipeline trigger's
           expected artifact settings."
%}

### In a Pipeline Stage

When configuring a "Deploy (Manifest)" or "Deploy" stage, you can use a
Kubernetes object as a manifest or application artifact.

{%
  include
  figure
  image_path="./deploy-manifest-stage-kubernetes-object.png"
  caption="Configuring a Deploy (Manifest) stage to use a Kubernetes object as
           a manifest source."
%}

## Kubernetes Object Artifact in a Pipeline Definition

The following are the fields that make up a Kubernetes object artifact:

| Field             | Explanation                                                                                                                               |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `type`            | `kubernetes/<kind>`, where `<kind>` is the Kubernetes Kind (such as `Deployment`).                                                        |
| `reference`       | The name of the object.                                                                                                                   |
| `name`            | The name of the object.                                                                                                                   |
| `version`         | The version of the object. Only set if the resource was deployed with a version (for example, a `ConfigMap` deployed at version `-v120`). |
| `location`        | The namespace of the object.                                                                                                              |
| `artifactAccount` | The Spinnaker account (Kubernetes context) to which the object was deployed.                                                              |

The following is an example JSON representation of a Kubernetes object artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "kubernetes/deployment",
  "reference": "frontend",
  "name": "frontend",
  "namespace": "staging",
  "artifactAccount": "gke-us-central1-xnat"
}
```
