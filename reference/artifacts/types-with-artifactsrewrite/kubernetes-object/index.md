---
layout: single
title:  "Kubernetes Object"
sidebar:
  nav: reference
---

{% include toc %}

Kubernetes Object artifacts are _running_, _deployed_ Kubernetes Manifests.
This is in contrast to something like a GitHub file that only contains the
specification of a deployable Kubernetes Manifest.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | `kubernetes/<kind>`, where `<kind>` is the Kubernetes Kind, such as `Deployment`. |
| `reference` | The name of the object. |
| `name` | The name of the object. |
| `version` | Only set when the resource was deployed with a version. A `ConfigMap` at version `-v120` is an example. |
| `location` | The object's namespace. |
| `artifactAccount` | The Spinnaker account (Kubernetes context) this was deployed to. |

## Example

```json
{
  "type": "kubernetes/deployment",
  "reference": "frontend",
  "name": "frontend",
  "namespace": "staging",
  "artifactAccount": "gke-us-central1-xnat"
}
```
