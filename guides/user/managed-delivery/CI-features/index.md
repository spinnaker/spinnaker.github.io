---
layout: single
title:  "CI features"
sidebar:
  nav: guides
---

{% include toc %}

One of the goals of Managed Delivery is to show you the journey of your code, from commit to deployment,
in an easy, consistent way.
In order to enable this experience, we created an integration between Managed Delivery and the Continuous Integration (CI) provider, which is described below.

### Note: in order to get it working for you, you'll have to integrate your CI provider. Please see our guide on [CI integration](/guides/developer/extending/integrate-your-CI).

## Artifact metadata

Detailed metadata (like commit message, author, timestamp) is visible in the Environments view in the UI, by clicking on an artifact version.

Here's what it looks like in the UI:
{%
  include
  figure
  image_path="./artifact-metadata.png"
%}


## See code changes between deployments

Now that we have git metadata for each artifact, we can easily figure out the code differences between each version.
We added the `See changes` button in the UI, for each environment, which looks like this:
{%
  include
  figure
  image_path="./see-changes.png"
%}

In Slack notifications:
{%
  include
  figure
  image_path="./slack-see-changes.png"
%}


## Surface build information in the UI
{%
  include
  figure
  image_path="./build-info.png"
%}

A new section called "Pre-deployment" is now available in the UI. This section will surface pre-deployment steps like baking (for Debian packages only) or building.
By clicking on "See details", you'll be taken to the CI view (see below), or a default job log which you can provide as a part of your implementation, see more [here](/guides/developer/extending/integrate-your-CI/#Surface-build-information-in-the-UI).

## CI view in Spinnaker

We recently added the option to see CI details in Spinnaker, in a new `Builds` tab.
It looks like this:
{%
  include
  figure
  image_path="./ci-view.png"
%}

This is a new tab that can be accessed from the main Spinnaker UI.
