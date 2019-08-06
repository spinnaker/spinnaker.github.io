---
layout: single
title:  "Overview"
sidebar:
  nav: guides
---

{% include toc %}

> The guides listed below assume that you have enabled the `artifactsRewrite`
> feature flag. In `~/.hal/$DEPLOYMENT/profiles/settings-local.js` (where
> `$DEPLOYMENT` is typically `default`), add:
>
> `window.spinnakerSettings.feature.artifactsRewrite = true;`

A pipeline trigger defines when to automatically run a pipeline. There are many
types of triggers available: Jenkins jobs, webhooks, CRON jobs, even other
pipelines. Adding a trigger to your pipeline means that the pipeline runs each
time the triggering event occurs.

Note that whether or not you have set up a pipeline trigger, you can always
[run your pipeline manually](/guides/user/pipeline/managing-pipelines#manually-run-a-pipeline).

For more information about how to configure
specific types of triggers, see the rest of the pipeline triggers
documentation:

<!-- TODO:add other links as they're added. -->
* [Triggering on Jenkins job completion](/guides/user/pipeline/triggers-with-artifactsrewrite/jenkins/)
* [Triggering on Pub/Sub messages](/guides/user/pipeline/triggers-with-artifactsrewrite/pubsub/)
* [Triggering on webhooks](/guides/user/pipeline/triggers-with-artifactsrewrite/webhooks/)
* [Triggering on receiving artifacts from GCS](/guides/user/pipeline/triggers-with-artifactsrewrite/gcs/)
* [Triggering on receiving artifacts from GitHub](/guides/user/pipeline/triggers-with-artifactsrewrite/github/)
* [Triggering on Artifactory artifact publishing](/guides/user/pipeline/triggers-with-artifactsrewrite/artifactory/)
