---
layout: single
title:  "Configuring GitHub Webhooks"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker can be configured to listen to changes to a repository in
[GitHub](https://github.com){:target="\_blank"}. These steps show you how to
configure webhook push events to send to Spinnaker from a single GitHub repository.

## Prerequisites

* You need Spinnaker's API running on an endpoint that is publicly reachable.
  Ideally this means that you've configured
  [authentication](/setup/security/authentication). This is required to allow
  GitHub's webhooks to reach Spinnaker.

  If you're unsure of what your Spinnaker API endpoint is, check the value of
  `services.gate.baseUrl` in `~/.hal/$DEPLOYMENT/staging/spinnaker.yml`. The
  value of `$DEPLOYMENT` is typically `default`. If you're unsure, see the
  [Halyard reference](/reference/halyard).

* You need a [GitHub
  repository](https://help.github.com/articles/create-a-repo/){:target="\_blank"}
  to send Webhooks from.

## Configuring your GitHub webhook

Under your GitHub repository, navigate to __Settings__ > __Webhooks__ > __Add
Webhook__. Here, provide the following values to the form shown below:

| Field | Value |
|-------|-------|
| __Payload URL__ | Given that the above [prerequisite](#prerequisites) API endpoint is `$ENDPOINT`, enter `$ENDPOINT/webhooks/git/github`. _While all GitHub webhooks share an endpoint in Spinnaker, there is no practical limit to the number of repositories you can configure to send notifications_. |
| __Content type__ | `application/json` |
| __Secret__ | The value is up to you, and must be provided to any GitHub webhooks triggers that you configure within Spinnaker. It's used to ensure that only GitHub can trigger your pipelines, not an imposter. |

{%
   include figure
   image_path="./github-webhook.png"
%}

## Spinnaker configuration

You do not need to configure Spinnaker via Halyard at this point -- all that's
needed is pipeline trigger configuration. An example of that can be found in
[this guide](/guides/user/artifacts/github).
