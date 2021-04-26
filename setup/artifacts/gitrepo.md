---
layout: single
title:  "Configure a Git Repo Artifact Account"
sidebar:
  nav: setup
---

{% include toc %}

## Overview

This shows how to configure a Git repo artifact account so that Spinnaker can use an entire repo as a single artifact.

Each time a pipeline needs a Git repo artifact during execution, Clouddriver clones the entire repo, sends the repo artifact to the pipeline, and then deletes the cloned repo immediately.

Spinnaker 1.26+ includes a feature for caching a Git repo artifact. Clouddriver clones the Git repo the first time a pipeline needs it and then caches the repo for a configured retention time. Each subsequent time the pipeline needs to use that Git repo artifact, Clouddriver does a `git pull` to fetch updates rather than cloning the entire repo again. This behavior is especially useful if you have a large repo. Clouddriver deletes the cloned Git repo when the configured retention time expires.  **This is an opt-in feature that is disabled by default.** See the [Enable `git pull` support](#enable-git-pull-support) section for details.

## Prerequisites

* You need a Git account.


## Enable Git Repo artifacts

First, enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).

Next, enable the Git Repo artifact provider:

```bash
hal config artifact gitrepo enable
```

## Configure auth

Choose to set up token, user-password, or ssh key auth.

### Token auth

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


### User-Password auth

1. Create a username-password file, with contents in the following format:

   ```
   <username>:<password>
   ```

1. Add an artifact account:

   ```bash
   hal config artifact gitrepo account add $ARTIFACT_ACCOUNT_NAME \
    --username-password-file $PASSWORD_FILE
   ```


### SSH key auth

Add an artifact account:

```bash
hal config artifact gitrepo account add $ARTIFACT_ACCOUNT_NAME \
    --ssh-private-key-file-path $SSH_KEY_FILE \
    --ssh-private-key-passphrase \
    --ssh-known-hosts-file-path $KNOWN_HOSTS_FILE

```

See the [Halyard reference](/reference/halyard/commands#hal-config-artifact-gitrepo-account-edit) for additional options.


## Enable `git pull` support

**Spinnaker version:** 1.26+

This feature is disabled by default. To enable `git pull` support, add the following `artifacts` section to your `clouddriver` profile:

```yaml
spec:
  spinnakerConfig:
    profiles:
      clouddriver:
        artifacts:
          gitrepo:
            clone-retention-minutes: 60
            clone-retention-max-bytes: 104857600
```

* `clone-retention-minutes:` Default: 0. How much time to keep clones. Values are:
  * 0: no retention.
  * -1: retain forever.
  * any whole number of minutes, such as `60`.
* `clone-retention-max-bytes:` Default: 104857600 (100 MB). Maximum amount of disk space to use for clones. When the maximum amount of space is reached, Clouddriver deletes the clones after returning the artifact to the pipeline, just as if retention were disabled.
