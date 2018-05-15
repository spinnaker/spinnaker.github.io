---
layout: single
title:  "Gitlab File"
sidebar:
  nav: reference
---

{% include toc %}

Gitlab file artifacts are references to files stored in
[Gitlab](https://gitlab.com). They are generally consumed
by stages that read configuration from text files, such as a Deploy Manifest
stage.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `gitlab/file`. |
| `reference` |  The full path including filename for retrieval via the GitHub API. `https://gitlab.example.com/api/v4/projects/13083/repository/files/manifests%2Fconfig%2Eyaml/raw` is an example from the Gitlab documentation. For more info, see the documentation [here](https://docs.gitlab.com/ee/api/repository_files.html#get-raw-file-from-repository).
| `name` | The file path within your repo. `path/to/file.yml` is an example. |
| `version` | The file's commit or branch. |
| `location` | N/A |

## Example

```json
{
  "type": "gitlab/file",
  "reference": "https://gitlab.example.com/api/v4/projects/13083/repository/files/manifests%2Fconfig%2Eyaml/raw",
  "name": "manifests/config.yaml",
  "version": "master"
}
```
