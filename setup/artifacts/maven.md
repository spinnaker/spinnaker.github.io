---
layout: single
title:  "Configure Maven Artifact Credentials"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker can be configured to deploy artifacts stored in a Maven repository.

You can configure more than one artifact account, each with separate
credentials. Specify which account to use in the configuration for the stage
that reads the data.

## Prerequisites

* A Maven repository

## Edit your artifact settings

1. Make sure that artifact support is enabled:

   ```bash
   hal config features edit --artifacts true
   hal config artifact maven enable
   ```

1. Add an artifact account:

   ```bash
   hal config artifact maven account add my-maven-account \
       --repository-url https://my.repo.example.com
   ```

There are more options described
[here](/reference/halyard/commands#hal-config-artifact-maven-account-edit)
if you need more control over your configuration.
