---
layout: single
title:  "Triggering on Pub/Sub Messages"
sidebar:
  nav: guides
---

{% include toc %}

> This guide assumes that you have enabled the `artifactsRewrite` feature flag.
> See [Prerequisites](#prerequisites).

In order to programatically trigger pipelines one can configure Spinnaker to
subscribe and listen to a Pub/Sub topic and push messages to the configured
topic. This can be used to trigger pipelines during CI jobs, from the command line,
or from a third-party system. The message payload will be available in the
Pipeline's execution.

> __☞ Note__:  It's possible to configure multiple pipelines to trigger off of
> a single Pub/Sub message.

Only Google Pub/Sub is supported. See the instructions
[here](/setup/triggers/google/) to set up Google Pub/Sub.

## Prerequisites

* Enable the `artifactsRewrite` feature flag in Spinnaker. In
  `~/.hal/$DEPLOYMENT/profiles/settings-local.js` (where `$DEPLOYMENT` is
  typically `default`), add the line
  `window.spinnakerSettings.feature.artifactsRewrite = true;`.

## Adding a Pub/Sub trigger to a pipeline

Assuming you have created a pipeline, under __Configuration__, select __Add
Trigger__ and make its type selector __Pub/Sub__.

To select a Pub/Sub subscription to trigger from, select values for
__Pub/Sub System Type__ and __Subscription Name__. Note that the subscription
must be configured before it is available to select in the UI.

{%
  include
  figure
  image_path="./basic-pubsub.png"
%}

### Payload constraints

If you want to ensure that a Pub/Sub trigger only fires when a certain message payload
arrives, you can provide __Payload Constraints__ in the trigger. These are
key/value pairs where the key must be found in the incoming message payload, and the
value must match using regex.

For example, if we had configured:

{%
  include
  figure
  image_path="./payload-constraints.png"
  caption="For clarity, the constraints are `mykey = myvalue` and `bing = b.*p`."
%}

The following message payload would be accepted:

```json
{
  "mykey": "myvalue",
  "bing": "boooop",
  "x": ["1", "2", "3"]
}
```

But this message payload would be rejected (pipeline would not trigger):

```json
{
  "mykey": "myvalue",
  "x": ["1", "2", "3"]
}
```

## Passing parameters

Say your pipeline accepted some parameters (for example, the desired stack to
deploy to), you can make this explicit by adding a pipeline parameter on the
same configuration screen as the Pub/Sub trigger:

{%
  include
  figure
  image_path="./parameters.png"
  caption="For more information on how to use pipeline parameters, see the
  [pipeline expressions guide](/guides/user/pipeline-expressions)."
%}

If you were to manually execute this pipeline, you would be prompted with the
following dialogue:

{%
  include
  figure
  image_path="./manual-execution.png"
%}

If instead you were to trigger this pipeline with a Pub/Sub Trigger, you could supply
each parameter a value inside a key/value map called `parameters` in the message body. Take the
following message payload for example:

```json
{
  "parameters": {
    "stack": "prod"
  }
}
```

> __☞ Note__: If you had selected the __Required__ checkbox for a parameter
> without providing a default, the pipeline doesn't trigger if a parameter is
> not present. The difference between this and the preconditions covered
> earlier is that when a precondition isn't met, Spinnaker will not even try to
> run the pipeline. However, when a required parameter doesn't exist, Spinnaker
> will try and fail to run a pipeline, surfacing a "Failed Execution" in the
> UI.

## Passing artifacts

If your pipeline requires artifacts (for example, a Kubernetes manifest file
stored in GCS), you can make this explicit by defining an __Expected Artifact__
and assigning it to the Pub/Sub Trigger. Under **Artifact Constraints**, select
**Define a new artifact...** and supply the artifact details, as shown below:

{%
  include
  figure
  image_path="./pubsub-artifact.png"
%}

{%
  include
  figure
  image_path="./artifact-constraints.png"
%}

In order for this to work, you need to supply the required artifact in the
Pub/Sub message payload, and configure Spinnaker so that it can translate the
Pub/Sub payload into a Spinnaker artifact.

If you're using GCR, you can use the `--message-format` flag and Spinnaker will
translate the payload automatically:

```
hal config pubsub google subscription edit my-gcr-subscription \
  --message-format GCR
```

Otherwise, you need to supply a translation template so that Spinnaker can
translate the Pub/Sub payload into a Spinnaker artifact. To do this, create a
[Jinja template](http://jinja.pocoo.org/docs/2.10/templates). Note that the
output of the Jinja transform must be a JSON list of Spinnaker artifacts. The
translation template itself can be any valid Jinja transform.

Use the following `hal` command to tell Spinnaker how to find the template:

```
hal config pubsub google subscription edit my-gcs-subscription \
  --template-path /path/to/jinja/template
```

### Example
Let's say you have a message payload containing the following structure:

```json
{
  ...
  "location": "gs://jtk54-artifacts/manifest.yml"
  ...
}
```

You can use the following Jinja template to translate the above into the
Spinnaker artifact format:

```
[
  {
    "type": "gcs/object", # static type.
    "reference": "{{"{{ location "}}}}", # 'location' in the Pub/Sub payload.
  }
]
```
