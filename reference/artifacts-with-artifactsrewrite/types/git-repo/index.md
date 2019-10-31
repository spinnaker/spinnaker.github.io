---
layout: single
title:  "Git Repo"
sidebar:
  nav: reference
---

{% include toc %}

Git Repo artifacts are references to Git repositories that are hosted by a Git hosting service. They are consumed
by stages that need multiple files to produce an output such as the Bake (Manifest) stage when using the Kustomize template
renderer. Unlike other artifact implementation, the Git Repo artifact will work with any Git hosting service as long as the
repository can be cloned using the Git CLI.

## Git Repo artifact in the UI

The pipeline UI exposes the following fields for the GitHub file artifact:

<table>
  <thead>
    <tr>
      <th>Field</th>
      <th>Explanation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Account</strong></td>
      <td>A Git Repo artifact account.</td>
    </tr>
    <tr>
      <td><strong>URL</strong></td>
      <td>HTTP or SSH URL of your Git repository. Artifact accounts configured to use a username and password should use HTTP while accounts configured to use an SSH private key should use the SSH URL format.</td>
    </tr>
    <tr>
      <td><strong>Branch</strong></td>
      <td>Name of the branch to check out. Default is `master`.</td>
    </tr>
    <tr>
      <td><strong>Sub Path (optional)</strong></td>
      <td>Relative path of files within the repository to fetch. If set, only files this path will be available to stages consuming this artifact.</td>
    </tr>
  </tbody>
</table>

### In a trigger

Work to support Git Repo artifacts in tiggers is currently underway. 

### In a pipeline stage

When configuring the "Bake (Manifest)" stage you can use a Git Repo artifact as an expected artifact.

{%
    include
    figure
    image_path="./bake-manifest-stage-git-repo.png"
    caption="Configure a Bake (Manifest) stage to use a Git Repo artifact"
%}

## Git Repo artifact in a pipeline definition

| Field              | Explaination                                                                                                                                                                                            |
|--------------------|--------|
| `type`             | Always `git/repo`.                                                                                                                                                                                       |
| `reference`        |  HTTP or SSH URL of your Git repository. Artifact accounts configured to use a username and password should use HTTP while accounts configured to use an SSH private key should use the SSH URL format. |
|  `version`         | Name of the branch to check out. Default is `master`.                                                                                                                                                   |
| `metadata.subPath` |  Relative path of files within the repository to fetch. If set, only files this path will be available to stages consuming this artifact.                                                               |

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