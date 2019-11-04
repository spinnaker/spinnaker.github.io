---
layout: single
title:  "Git Repo"
sidebar:
  nav: reference
---

<div class="notice--info">
    <strong>The Git Repo artifact will be introduced in the upcoming 1.17 release.</strong>
</div>

{% include toc %}

Git Repo artifacts are references to Git repositories that are hosted by a Git hosting service. They are consumed
by stages that need multiple files to produce an output, such as the Bake (Manifest) stage when using the Kustomize template
renderer. Unlike other artifact implementations, the Git Repo artifact works with any Git hosting service as long as the
repository can be cloned using the Git CLI.

## Git Repo artifact in the UI

The pipeline UI exposes the following fields for the GitHub file artifact:

| Field | Explaination |
| ------|--------------|
|Account| A Git Repo artifact account. |
|URL| HTTP or SSH URL of your Git repository. Artifact accounts configured to use a username and password should use HTTP while accounts configured to use an SSH private key should use the SSH URL format. |
|Branch| Name of the branch to check out. Default is `master`. |
|Sub Path (Optional) | Relative path of files within the repository to fetch. If set, only files this path will be available to stages consuming this artifact. |

### In a trigger

_Work to support Git Repo artifacts in triggers is currently underway._

### In a pipeline stage

When configuring the "Bake (Manifest)" stage, you can use a Git Repo artifact as an expected artifact.

{%
    include
    figure
    image_path="./bake-manifest-stage-git-repo.png"
    caption="Configure a Bake (Manifest) stage to use a Git Repo artifact."
%}

## Git Repo artifact in a pipeline definition

| Field              | Explaination                                                                                                                                                                                            |
|--------------------|--------|
| `type`             | Always `git/repo`.                                                                                                                                                                                       |
| `reference`        |  HTTPS or SSH URL of your Git repository. Artifact accounts configured to use a username and password should use HTTPS while accounts configured to use an SSH private key should use the SSH URL format. |
|  `version`         | Name of the branch to check out. Default is `master`.                                                                                                                                                   |
| `metadata.subPath` |  Relative path of files within the repository to fetch. If set, only files in this path are available to stages consuming this artifact.                                                               |

**Artifact accounts using an SSH private key for authentication.**

```json
{
    "type": "git/repo",
    "reference": "git@github.com:spinnaker/spinnaker.github.io",
    "version": "feat-123"
}
```

**Artifact accounts using a username and password _or_ token for authentication.**

```json
{
    "type": "git/repo",
    "reference": "https://github.com/spinnaker/spinnaker.github.io",
    "version": "feat-123"
}
```

**When checking out an explicit sub path within repository.**

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
