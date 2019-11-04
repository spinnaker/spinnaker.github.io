---
layout: single
title:  "Git Repo"
sidebar:
  nav: reference
---

**The Git Repo artifact is available in version 1.17 or later.**
{: .notice--info}

{% include toc %}

Git Repo artifacts are references to Git repositories that are hosted by a Git hosting service. They are consumed
by stages that need multiple files to produce an output such as the Bake (Manifest) stage when using the Kustomize template
renderer. Unlike other artifact implementation, the Git Repo artifact will work with any Git hosting service as long as the
repository can be cloned using the Git CLI.

## Fields


| Field              | Explanation                                                                                                                                                                                            |
|--------------------|--------|
| `type`             | Always `git/repo`.                                                                                                                                                                                       |
| `reference`        |  HTTP or SSH URL of your Git repository. Use HTTP for artifact accounts configured to use a username and password, and use the SSH URL format for accounts configured to use the SSH private key. |
|  `version`         | Name of the branch to check out. Default is `master`.                                                                                                                                                   |
| `metadata.subPath` |  Relative path of files within the repository to fetch. If set, only files this path will be available to stages consuming this artifact.                                                               |


## Example

### Artifact accounts using an SSH private key for authentication.

```json
{
    "type": "git/repo",
    "reference": "git@github.com:spinnaker/spinnaker.github.io",
    "version": "feat-123"
}
```

### Artifact accounts using a username and password _or_ token for authentication.

```json
{
    "type": "git/repo",
    "reference": "https://github.com/spinnaker/spinnaker.github.io",
    "version": "feat-123"
}
```

### When checking out an explicit sub path within repository

```json
{
    "type": "git/repo",
    "reference": "https://github.com/spinnaker/spinnaker.github.io",
    "version": "feat-123",
    "metadata" : {
        "subPath": "reference/artifacts/types"
    }
}
```
