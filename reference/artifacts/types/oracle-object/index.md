---
layout: single
title:  "Oracle Object"
sidebar:
  nav: reference
---

{% include toc %}

[Oracle Object Storage](https://docs.cloud.oracle.com/iaas/Content/Object/Concepts/objectstorageoverview.htm) is an object store,
and Oracle Object Storage object artifacts are references to objects stored in Oracle Object Storage buckets.
These artifacts are generally consumed by stages that read configuration from text files, for example a Deploy Manifest stage.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `oracle/object`. |
| `reference` | The `oci://`-prefixed reference to your file. Following the bucket name is the path to your file. |

## Example

```json
{
  "type": "oracle/object",
  "reference": "oci://bucket/file.json"
}
```
