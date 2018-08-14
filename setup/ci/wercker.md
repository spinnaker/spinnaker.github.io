---
layout: single
title:  "Wercker"
sidebar:
  nav: setup
---

{% include toc %}

[Wercker](http://www.wercker.com) is a cloud CI system, which can be 
enabled within Spinnaker as a pipeline trigger and also as a pipeline stage. The setup required
is described below.

## Prerequisites

To enable Wercker integration in Spinnaker, you will need to have:
- A login to Wercker, which can be set up [here](https://app.wercker.com/).
- A Wercker "personal token" to provide to Spinnaker so that it can access 
the Wercker API on your behalf. Personal tokens [can be generated](https://devcenter.wercker.com/development/api/authentication/)
on Wercker by logging in and visiting your "Settings" page.

## Add a Wercker 'Master' to Spinnaker Using Halyard
A "master" is a connection to Wercker from Spinnaker. It consists of the Wercker URL 
and credentials.
1. First, make sure that the Wercker CI integration is enabled:

   ```bash
   hal config ci wercker enable
   ```

2. And that the Wercker stage feature flag is turned on:

   ```bash
   hal config features edit --wercker true
   ```

3. Next, add a Wercker master i.e. a connection to Wercker from Spinnaker.
      ```bash
      hal config ci wercker master add mywercker1
          --address https://app.wercker.com/ 
          --user myuserid 
          --token
      ```

4. Apply your changes:

   `hal deploy apply`

## Wercker as Pipeline Trigger
When configuring a Spinnaker Pipeline, Wercker is available as one of the [automated
trigger](/guides/user/pipeline/managing-pipelines/#add-a-trigger) type options. You can
select a Wercker master that you configured earlier, and then choose from the applications and
pipelines available for the configured master's credentials. When the selected Wercker pipeline
completes, it will trigger the Spinnaker pipeline.

## Wercker as Pipeline Stage
When [adding a pipeline stage](/guides/user/pipeline/managing-pipelines/#add-a-stage), Wercker is
available as one of the stage types in Spinnaker. For details, see the
[pipeline stage reference](/reference/pipeline/stages/#wercker)

## Links
[Main Wercker Site](https://app.wercker.com)

[Wercker Documentation](https://devcenter.wercker.com/)
