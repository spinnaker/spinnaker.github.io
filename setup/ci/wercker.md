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

## Links
[Main Wercker Site](https://app.wercker.com)

[Wercker Documentation](https://devcenter.wercker.com/)

## Prerequisites

To enable Wercker integration in Spinnaker, you will need to have:
1. A login to Wercker, which you can set up at https://app.wercker.com/
2. A Wercker "personal token" to provide to Spinnaker so that it can access 
the Wercker API on your behalf. Personal tokens can be generated on Wercker by logging in 
and visiting your "Settings" page.

## Add a Wercker 'Master' to Spinnaker Using Halyard
A "master" is a connection to Wercker from Spinnaker. It consists of the Wercker URL 
and credentials.
1. First, make sure that Wercker is enabled:

   ```bash
   hal config ci wercker enable
   ```

2. Next, add a Wercker master i.e. a connection to Wercker from Spinnaker.
      ```bash
      hal config ci wercker master add mywercker1
          --address https://app.wercker.com/ 
          --user myuserid 
          --token
      ```

3. Apply your changes:

   `hal deploy apply`

## Wercker as Pipeline Trigger
When configuring a Spinnaker Pipeline, Wercker will be available as one of the automated 
trigger type options. You will be able to select a Wercker master that you configured earlier,
and then choose from the applications and pipelines available for the configured master's
credentials. When the selected Wercker pipeline completes, it will trigger the Spinnaker pipeline.

## Wercker as Pipeline Stage
When adding a pipeline stage, Wercker will be available as one of the stage types in Spinnaker. The
Wercker masters configured, and the applications and pipelines available for your master's 
credentials.
When a Wercker Stage runs in a Spinnaker pipeline, a link to the Wercker run will be
available, and the status of the Wercker run will be reported in Spinnaker.
