---
layout: single
title:  "HTTP File"
sidebar:
  nav: reference
---

{% include toc %}

HTTP file artifacts are references to files stored in plaintext reachable via
HTTP. They are generally consumed by stages that read configuration from text
files, such as a Deploy Manifest stage. 

These files can be downloaded using basic auth.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `http/file`. |
| `reference` | The fully-qualified URL where your file can be read from. |
| `name` | An optional identifier for referencing this artifact later. |
| `version` | N/A |
| `location` | N/A |

## Example

```json
{
  "type": "http/file",
  "reference": "https://raw.githubusercontent.com/....",
  "name": "My manifest stored in github",
}
```
