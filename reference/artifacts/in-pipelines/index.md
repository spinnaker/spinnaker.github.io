---
layout: single
title:  "Artifacts In Pipelines"
sidebar:
  nav: reference
---

{% include toc %}

> :warning: Much of the behavior described here depends on looking up execution
> history in Redis. Deleting recent executions from Redis can cause
> unexpected behavior.

Now that you have an idea of [what an artifact is](../#about-spinnaker-artifacts) in Spinnaker, you need to
understand how it's used within pipelines. An artifact arrives in a pipeline execution either from an external trigger (for example, code check-in) or by getting fetched by a stage. That artifact is then consumed by downstream stages based on pre-defined behavior. 

Spinnaker uses an "expected artifact" to enable a stage to fetch the needed artifact.

# Expected Artifacts

An "expected artifact" is a specification of what properties (found in the URI decoration) against which to match when searching for the desired artifact.

Expected artifacts exist for two reasons:

1. To declare what artifacts need to be present at a certain point during
   execution
2. To provide easy ways to reference those artifacts

An expected artifact consists of an artifact to _match_
(by name, type, etc...) plus, optionally, what to do if no artifact is
matched.  When an artifact is matched, we say it's _bound_ to that expected
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

> If an expected artifact matches anything other than a
> single artifact (and no fallback behavior is defined), the execution fails.
> Therefore it's always safe to say "use the artifact bound by
> this upstream expected artifact" because if no artifact was bound, the pipeline
> wouldn't be running this downstream stage.

## Triggers

In Pipeline Configuration, you can now declare which
artifacts a pipeline expects to have present before the pipeline starts
running.

{% include figure
   image_path="./expected-artifact-trigger.png"
   caption="The UI provides short-hand for defining some types of
            artifacts&mdash;in this example a docker image. This is optional, but helps
            quickly define common types of artifacts."
%}

You can define fallback behavior for when the artifact
isn't bound at the start of the Pipeline. The two options are evaluated in
order:

1. __Use Prior Execution__

   Use the artifact bound by the pipeline's previous execution. This is useful in cases where multiple
   sources can trigger the pipeline, but each has incomplete information about
   what artifacts to supply.

2. __Use Default Artifact__

   Specify exactly which artifact to bind.

Once you have declared which artifacts are expected by this pipeline, you can
assign expected artifacts to individual triggers.

{% include figure
   image_path="./pubsub-trigger-artifact.png"
   caption="A pubsub subscription configured to listen to changes in
            one GCR registry. Since this registry can contain many
            repositories, we've assigned it an expected artifact to ensure only
            changes in one repository can run this pipeline."
%}

When a trigger has one or more expected artifacts, it only runs when each
expected artifact can bind to one of artifacts in the trigger's payload.

### Artifacts in Trigger Payloads

Artifacts are supplied by payload as a list of artifacts in a top-level
`artifacts` key&mdash;the value is automatically injected into any triggered
pipeline's execution context. However, it's possible that you're not the author
of the incoming message, and are instead depending on a third-party system to
provide an event to Spinnaker to trigger a pipeline. If this event contains
information such as "these images were created," or "these files were
modified," it's useful to be able to extract artifacts from that payload.

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
