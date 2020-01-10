---
layout: single
title:  "Managed Delivery"
sidebar:
  nav: reference
---

{% include toc %}

Spinnaker supports git-based workflows to create and update Managed Delivery configurations.
This allows you to keep your Managed Delivery configuration in code and follow all the usual
best practices like code review and approvals before a change is introduced to your managed
resources, environments or deployments.
 
Git support is currently achieved via a pipeline configured with a 
[trigger](../../../guides/user/pipeline/triggers/index.md) that can provide source repository
information (such as a Git trigger) and containing a single `Import Delivery Config` stage.
This stage will retrieve a Delivery Config manifest from the repository associated with your
pipeline's trigger, then save (or update) it in Spinnaker so it will automatically monitor
and manage the resources, environments and deployments described in the manifest.

Here's what it looks like in the UI:
{%
  include
  figure
  image_path="./import-delivery-config.png"
%}

Configuration is very straightforward: your Spinnaker operator will have configured a default
"base path" under which to look for manifest files in your source code repos (`.spinnaker`,
in this example) and you only need to specify the name of the manifest file if it's not the
default shown in the placeholder text (`spinnaker.yml`, in the example).

Eventually, we might add support for direct monitoring of git commit events to Managed Delivery
so that you don't even need a pipeline, but for now, this is the way to do it.
