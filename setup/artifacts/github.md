---
layout: single
title:  "Configuring GitHub Webhooks"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker can be configured to listen to changes to a repository in
[GitHub](https://github.com). These steps show you how to configure a GitHub
artifact account so that Spinnaker can download files from GitHub.

## Prerequisites

* You need a [GitHub](https://github.com) account.

### Downloading credentials

Start by generating an [access token](https://github.com/settings/tokens) for
GitHub. The token requires the __repo__ scope. 

Place the token in a file (`$TOKEN_FILE`) readable by Halyard:

```bash
echo $TOKEN > $TOKEN_FILE
```

## Editing Your Artifact Settings

All that's required are the following values:

```bash
# See the prerequisites section above
TOKEN_FILE=

ARTIFACT_ACCOUNT_NAME=my-github-artifact-account
```

First, make sure that artifact support is enabled:

```bash
hal config features edit --artifacts true
hal config artifact github enable
```

Next, add an artifact account:

```bash
hal config artifact github account add $ARTIFACT_ACCOUNT_NAME \
    --token-file $TOKEN_FILE
```

There are more options described
[here](/reference/halyard/commands#hal-config-artifact-github-account-edit)
if you need more control over your configuration.
