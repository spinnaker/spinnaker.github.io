---
layout: single
title:  "Embedded base64"
sidebar:
  nav: reference
---

{% include toc %}

Rather than refer to a resource by URI, you can embed the artifact's contents
directly into the `"reference"` field in base64.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `embedded/base64`. |
| `reference` | The base64 encoded artifact contents. |
| `name` | An optional human-readable identifier. |

## Example

```json
{
  "type": "embedded/base64",
  "reference": "dmFsdWU6IDEKZm9vOiBiYXIK",
  "name": "my-properties-file",
}
```
