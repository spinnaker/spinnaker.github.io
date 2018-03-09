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
configuration is needed, Spinnaker will automatically add a
`no-auth-http-account` for this purpose.

## Prerequisites

1. Collect your basic auth `$USERNAME` and `$PASSWORD`
2. Pick a `$USERNAME_PASSWORD_FILE` location on your disk
3. Run:

   ```bash
   echo ${USERNAME}:${PASSWORD} > $USERNAME_PASSWORD_FILE
   ```

## Edit Your Artifact Settings

1. Collect the `$USERNAME_PASSWORD_FILE` value returned from the
   [prerequisites](#prerequisites) section above.

2. Make sure that artifact support is enabled:

   ```bash
   hal config features edit --artifacts true
   ```

3. Add an artifact account:

   ```bash
   hal config artifact http account add my-http-account \
       --username-password-file $USERNAME_PASSWORD_FILE
   ```
