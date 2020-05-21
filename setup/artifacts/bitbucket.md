---
layout: single
title:  "Configure Bitbucket Artifact Credentials"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker stages that read data from artifacts can read Bitbucket files directly.

If the files are hidden behind basic auth, you can configure an artifact
account with the needed credentials to read your artifact.

## Prerequisites

1. Collect your basic auth `$USERNAME` and `$PASSWORD`
2. Pick a `$USERNAME_PASSWORD_FILE` location on your disk
3. Run:

   ```bash
   echo ${USERNAME}:${PASSWORD} > $USERNAME_PASSWORD_FILE
   ```

## Edit your artifact settings

1. Collect the `$USERNAME_PASSWORD_FILE` value returned from the
   [prerequisites](#prerequisites) section above.
   
2. Enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).


2. Enable the Bitbucket artifact provider:

   ```bash
   hal config artifact bitbucket enable
   ```

3. Add an artifact account:

   ```bash
   hal config artifact bitbucket account add my-bitbucket-account \
       --username-password-file $USERNAME_PASSWORD_FILE
   ```

There are more options described
[here](/reference/halyard/commands#hal-config-artifact-bitbucket-account-edit)
if you need more control over your configuration.
