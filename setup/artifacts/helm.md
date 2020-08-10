---
layout: single
title:  "Configure Helm Artifact account"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker stages that consume artifacts can read from a Helm provider directly. The provider can be an Artifactory like [Nexus](https://help.sonatype.com/repomanager3/formats/helm-repositories), [JFrog](https://jfrog.com/integration/helm-repository/), or [Chartmuseum](https://chartmuseum.com/).

If the files are hidden behind basic auth, you can configure an artifact account with the needed credentials to read your artifacts. Basic auth is the only authentication mechanism supported for accessing a Helm artifact account.

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

3. Enable the Helm artifact provider:

   ```bash
   hal config artifact helm enable
   ```

4. Add an artifact account:

   ```bash
   hal config artifact helm account add my-helm-account \
       --username-password-file $USERNAME_PASSWORD_FILE
   ```

There are more options described [here](/reference/halyard/commands#hal-config-artifact-helm-account-edit) if you need more control over your configuration.
