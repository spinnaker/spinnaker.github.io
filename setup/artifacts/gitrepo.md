---
layout: single
title:  "Configure a Git Repo artifact account"
sidebar:
  nav: setup
---

{% include toc %}

This shows how to configure a Git Repo artifact account so Spinnaker can use an entire repository as a single artifact.

## Prerequisites

* You need a Git account.


## Enable Git Repo artifacts

First, enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).

Next, enable the Git Repo artifact provider:

```bash
hal config artifact gitrepo enable
```

## Configure Auth
Choose to set up either token, user-password or ssh key auth below.

### Token Auth

1. Generate an access token for your Git provider (eg, [GitHub](https://github.com/settings/tokens){:target="\_blank"} or [GitLab](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html){:target="\_blank"}). The token requires the __repo__ scope.

1. Place the token in a file (`$TOKEN_FILE`) readable by Halyard:

   ```bash
   echo $TOKEN > $TOKEN_FILE
   ```

1. Add an artifact account:

   ```bash
   hal config artifact gitrepo account add $ARTIFACT_ACCOUNT_NAME \
       --token-file $TOKEN_FILE
   ```


### User-Password Auth

1. Create a username-password file, with contents in the following format:

   ```
   <username>:<password>
   ```

1. Add an artifact account:

   ```bash
   hal config artifact gitrepo account add $ARTIFACT_ACCOUNT_NAME \
    --username-password-file $PASSWORD_FILE
   ```


### SSH Key Auth

Add an artifact account:

```bash
hal config artifact gitrepo account add $ARTIFACT_ACCOUNT_NAME \
    --ssh-private-key-file-path $SSH_KEY_FILE \
    --ssh-private-key-passphrase \
    --ssh-known-hosts-file-path $KNOWN_HOSTS_FILE 

```


There are more options described
[here](/reference/halyard/commands#hal-config-artifact-gitrepo-account-edit)
if you need more control over your configuration.
