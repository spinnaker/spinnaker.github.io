---
layout: single
title:  "Bitbucket File"
sidebar:
  nav: reference
---

{% include toc %}

Bitbucket file artifacts are references to files stored in
[Bitbucket](https://bitbucket.org). They are generally consumed
by stages that read configuration from text files, such as a Deploy Manifest
stage.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `bitbucket/file`. |
| `reference` |  The full path including filename for retrieval via the Bitbucket API. `https://api.bitbucket.org/1.0/repositories/$ORG/$REPO/raw/$VERSION/$FILEPATH`. For more info, see the documentation [here](https://confluence.atlassian.com/bitbucket/src-resources-296095214.html).
| `name` | The file path within your repo. `path/to/file.yml` is an example. |
| `version` | N/A. Must be specified in reference.|
| `location` | N/A |

## Example

```json
{
  "type": "bitbucket/file",
  "reference": "https://api.bitbucket.org/1.0/repositories/org/repo/raw/master/manifests/config.yaml",
  "name": "manifests/config.yaml"
}
```
