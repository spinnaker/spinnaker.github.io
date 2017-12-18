---
layout: single
title:  "Artifacts In Pipelines"
sidebar:
  nav: reference
---

{% include toc %}

> :warning: Much of the behavior defined here depends on looking up execution
> history within Redis. As a result, deleting recent executions from Redis is
> undefined behavior.

Once you have an idea of what an "artifact" is in Spinnaker, it's important to
understand how they are used within pipelines. The idea is simple, artifacts
arrive in a pipeline execution either from an external trigger or a stage, and
are consumed by downstream stages based on pre-defined behavior. In order to
explain how this works, we need to understand the concept of an "expected
artifact".

# Expected Artifacts

Expected artifacts exist for two reasons:

1. To declare what artifacts need to be present at a certain point during
   execution, and
2. To provide easy ways to reference artifacts declared in 1.

In implementation, an expected artifact consists of an artifact to __match__
(by name, type, etc...), and optionally, what to do if no artifact could be
matched.  When an artifact is matched, we say it's __bound__ to that expected
artifact.

The matching behavior is as follows: The artifact to match declared by the
expected artifact has the same format as a regular artifact; however, its
values are interpreted as regular expressions to match the corresponding values
in the incoming artifact.

| Match Artifact | Incoming Artifact | Matches?  |
|-|-|-|
| `{"type": "docker/image"}` | `{"type": "docker/image", "reference: "gcr.io/image"}` | ✔ |
| `{"type": "docker/image"}` | `{"type": "gce/image", "reference: "www.googleapis.com/compute/v1/projects..."}` | ✘ |
| `{"type": "docker/image", "version": "v1\..*"}` | `{"type": "docker/image", "reference: "gcr.io/image:v1.2", "version": "v1.2"}` | ✔ |
| `{"type": "docker/image", "version": "v1\..*"}` | `{"type": "docker/image", "reference: "gcr.io/image:test", "version": "test"}` | ✘ |

It's important to note: if an expected artifact matches anything other than a
single artifact (and no fallback behavior is defined), the execution will fail.
As a result, we can always assume it's safe to say "use the artifact bound by
this upstream expected artifact", because if no artifact was bound, the pipeline
wouldn't be running this downstream stage.

## Triggers

At the "Pipeline Configuration" page, it's now possible to declare which
artifacts a pipeline expects to have present before the pipeline starts
running.

{% include figure
   image_path="./expected-artifact-trigger.png"
   caption="The UI provides short-hand for defining some types of
            artifacts, in this case a docker image. This is optional, but helps
            quickly define common types of artifacts."
%}

In this case, it's possible to define fallback behavior for when this artifact
isn't bound at the start of the Pipeline. There are two options, evaluated in
order:

1. __Use Prior Execution__

   When selected, whatever artifact was bound by this artifact in the
   pipeline's prior execution is used. This is useful in cases where multiple
   sources can trigger the pipeline, but each has incomplete information about
   what artifacts to supply.

2. __Use Default Artifact__

   When selected, you can define by hand exactly which artifact to bind.

Once you have declared which artifacts are expected by this pipeline, you can
assign expected artifacts to individual triggers.

{% include figure
   image_path="./pubsub-trigger-artifact.png"
   caption="Above is a pubsub subscription configured to listen to changes in
            one GCR registry. Since this registry can contain many
            repositories, we've assigned it an expected artifact to ensure only
            changes in one repository can run this pipeline."
%}

When a trigger has one or more expected artifacts, it only runs when each
expected artifact can bind to one of artifacts in the trigger's payload.

### Artifacts in Trigger Payloads

Artifacts are supplied by payload as a list of artifacts in a top-level
`artifacts` key - the value is automatically injected into any triggered
pipeline's execution context. However, it's possible that you're not the author
of the incoming message, and are instead depending on a third-party system to
provide an event to Spinnaker to trigger a pipeline. If this event contains
information such as "these images were created", or "these files were
modified", it's useful to be able to extract artifacts from that payload.

For this reason, we allow you to supply [Jinja
templates](http://jinja.pocoo.org/) that transform the incoming payload into a
list of artifacts to be injected into your pipeline.

Take for example the [notification format for
GCR](https://cloud.google.com/container-registry/docs/configuring-notifications#notification_examples).
While it captures the information we need, it's not in the format we want. So,
we can register the following Jinja template for our GCR subscription:

```json
[
  {
    {% raw %}
    {% set split = digest.split("@") %}
    "reference": "{{ digest }}",
    "name": "{{ split[0] }}",
    "version": "{{ split[1] }}",
    "type": "docker/image"
    {% endraw %}
  }
]
```

## Find Artifact from Execution

To allow you to promote artifacts between executions, you can make use of the
"Find Artifact from Execution" stage. All that's required is the pipeline ID
whose execution history to search, and an expected artifact to bind.

{% include figure
   image_path="./find-artifact-from-execution.png"
%}

A common use case would be to "promote" the image deployed to staging to a
pipeline that's deploying to production.
