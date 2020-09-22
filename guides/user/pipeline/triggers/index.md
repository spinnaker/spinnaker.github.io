---
layout: single
title:  "Overview"
sidebar:
  nav: guides
---

{% include toc %}

> This section describes configuring pipeline triggers with the legacy artifacts
> UI, which was removed in release 1.21. Please refer to the
> [guide](/guides/user/pipeline/triggers-with-artifactsrewrite/) for configuring
> pipeline triggers with the standard artifacts UI instead.

A pipeline trigger defines when to automatically run a pipeline. There are many
types of triggers available: Jenkins jobs, webhooks, CRON jobs, even other
pipelines. Adding a trigger to your pipeline means that the pipeline runs each
time the triggering event occurs.

> **Note:** Whether or not you have set up a pipeline trigger, you can always
> [run your pipeline manually](/guides/user/pipeline/managing-pipelines#manually-run-a-pipeline).

For more information about how to configure
specific types of triggers, see the rest of the pipeline triggers
documentation:

<!-- TODO:add other links as they're added. -->
* [Triggering on Jenkins job completion](/guides/user/pipeline/triggers/jenkins/)
* [Triggering on Pub/Sub messages](/guides/user/pipeline/triggers/pubsub/)
* [Triggering on webhooks](/guides/user/pipeline/triggers/webhooks/)
* [Triggering on receiving artifacts from GCS](/guides/user/pipeline/triggers/gcs/)
* [Triggering on receiving artifacts from GitHub](/guides/user/pipeline/triggers/github/)
