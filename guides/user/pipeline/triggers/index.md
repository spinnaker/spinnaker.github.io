---
layout: single
title:  "Overview"
sidebar:
  nav: guides
---

{% include toc %}

A pipeline trigger defines when to automatically run a pipeline. There are many
types of triggers available: Jenkins jobs, webhooks, CRON jobs, even other
pipelines. Adding a trigger to your pipeline means that the pipeline runs each
time the triggering event occurs. For more information about how to configure
specific types of triggers, see the rest of the pipeline triggers
documentation:

<!-- TODO:add other links as they're added. -->
* [Triggering on Pub/Sub messages](/guides/user/pipeline/triggers/pubsub/)
* [Triggering on webhooks](/guides/user/pipeline/triggers/webhooks/)
* [Triggering on receiving artifacts from GCS](/guides/user/pipeline/triggers/gcs/)
* [Triggering on receiving artifacts from GitHub](/guides/user/pipeline/triggers/github/)
