---
layout: single
title:  "Oracle Object"
sidebar:
  nav: reference
---

{% include toc %}

[Oracle Object Storage](https://docs.cloud.oracle.com/iaas/Content/Object/Concepts/objectstorageoverview.htm) is an object store, and an Oracle Object Storage object artifact is a reference to an object stored in an Oracle Object Storage bucket.
These artifacts are generally consumed by stages that read configuration from text files, such as a Deploy Manifest stage.

## Oracle Object Artifact in a Pipeline Definition

The following are the fields that make up an Oracle object artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `oracle/object`. |
| `reference` | The full path to the artifact file, beginning with`oci://`. |

The following is an example JSON representation of an Oracle object artifact, as it would appear in a pipeline definition:

```json
{
  "type": "oracle/object",
  "reference": "oci://bucket/file.json"
}
```
