---
layout: single
title:  "GitHub File"
sidebar:
  nav: reference
---

{% include toc %}

GitHub file artifacts are references to files stored in
[GitHub](https://github.com) or [GitHub
Enterprise](https://enterprise.github.com/home). They are generally consumed
by stages that read configuration from text files, such as a Deploy Manifest
stage.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `github/file`. |
| `reference` |  The full path including filename for retrieval via the GitHub API. This is the `contents_url` as referenced by a [PushEvent](https://developer.github.com/v3/activity/events/types/#pushevent). `https://api.github.com/repos/baxterthehacker/public-repo/contents/path/to/file.yml` is an example for public GitHub. `https://github.mydomain.com/api/v3/repos/orgname/reponame/contents/path/to/file.yml` is an example for GHE. |
| `name` | The file path within your repo. `path/to/file.yml` is an example. |
| `version` | The file's commit or branch. |
| `location` | N/A |

## Example

```json
{
  "type": "github/file",
  "reference": "https://api.github.com/repos/baxterthehacker/public-repo/contents/path/to/file.yml",
  "name": "path/to/file.yml",
  "version": "aec855f4e0e11"
}
```
