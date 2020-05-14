---
layout: single
title:  "Configure HTTP Artifact Credentials"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker stages that read data from artifacts can read HTTP files directly.

If the files are hidden behind basic auth, you can configure an artifact
account with the needed credentials to read your artifact. _If not_, no further
configuration is needed, Spinnaker automatically adds a
`no-auth-http-account` for this purpose.

You can configure more than one artifact account, each with separate
credentials. Specify which account to use in the configuration for the stage
that reads the data. If you have only one such account configured, the stage
config for this is hidden, and the single account is automatically used.

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

3. Enable the HTTP artifact provider:

   ```bash
   hal config artifact http enable
   ```

4. Add an artifact account:

   ```bash
   hal config artifact http account add my-http-account \
       --username-password-file $USERNAME_PASSWORD_FILE
   ```

There are more options described
[here](/reference/halyard/commands#hal-config-artifact-http-account-edit)
if you need more control over your configuration.
