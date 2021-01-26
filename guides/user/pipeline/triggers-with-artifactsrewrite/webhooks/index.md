---
layout: single
title:  "Triggering on Webhooks"
sidebar:
  nav: guides
---

{% include toc %}

In order to programatically trigger pipelines you can send a `POST` call to
Spinnaker at a preconfigured endpoint. You can use this to trigger pipelines
when a CI job finishes, from the command line, or from a third-party system.
The payload, whether it is one you are able to write, or it is provided for
you, will be available in the Pipeline's execution.

> __☞ Note__:  You can configure multiple pipelines to trigger off of a single
> webhook.

If you're triggering from a *GitHub* webhook, see the instructions
[here](/setup/triggers/github/) to set up that webhook.

## Prerequisites

* Artifact support [enabled](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).

## Adding a webhook trigger to a pipeline

Assuming you've created a pipeline, under __Configuration__, select __Add
Trigger__ and make its type selector __Webhook__.

To assign an endpoint that must be hit, you can provide a value to the
__Source__ field as shown here:

{%
  include
  figure
  image_path="./basic-webhook.png"
%}

Notice that in the above image below the __Type__ dropdown, the webhook
configuration points out that we can hit
`http://localhost:8084/webhooks/webhook/demo` to trigger the pipeline. The
endpoint depends on how you've configured your [Spinnaker
endpoints](/setup/security) -- if you're running on a different endpoint, for
example `https://api.spinnaker-prod.net`, that'll be shown instead.

Keeping track of that endpoint as `$ENDPOINT` (it will depend on where
Spinnaker is installed), save that pipeline, and run:

```bash
curl $ENDPOINT -X POST -H "content-type: application/json" -d "{ }"
```

### Payload constraints

If you want to ensure that a webhook only triggers when a certain payload
arrives, you can provide __Payload Constraints__ in the trigger. These are
key/value pairs where the key must be found in the incoming payload, and the
value must match using regex.

For example, if we had configured:

{%
  include
  figure
  image_path="./constraints-webhook.png"
  caption="For clarity, the constraints are `mykey = myvalue` and `bing = b.*p`."
%}

The following payload would be accepted:

```json
{
  "mykey": "myvalue",
  "bing": "boooop",
  "x": ["1", "2", "3"]
}
```

But this payload would be rejected (pipeline would not trigger):

```json
{
  "mykey": "myvalue",
  "x": ["1", "2", "3"]
}
```

## Passing parameters

Say your pipeline accepted some parameters (for example, the desired stack to
deploy to), you can make this explicit by adding a pipeline parameter on the
same configuration screen as the webhook trigger:

{%
  include
  figure
  image_path="./parameters.png"
  caption="For more information on how to use pipeline parameters, see the
  [pipeline expressions guide](/guides/user/pipeline-expressions)."
%}

> Warning: there are several reserved parameter keys (names) that cause unexpected behavior and failures
> if overwritten by a pipeline parameter definition.
> See the [list of reserved parameter and evaluate variable key names](/guides/user/pipeline/expressions#list-of-reserved-parameter-and-evaluate-variable-key-names).


If you were to manually execute this pipeline, you would be prompted with the
following dialogue:

{%
  include
  figure
  image_path="./manual-execution.png"
%}

If instead you were to trigger this pipeline with a Webhook, you could supply
each parameter a value inside a key/value map called `parameters`. Take the
following payload for example:

```json
{
  "parameters": {
    "stack": "prod"
  }
}
```

> __☞ Note__: If you select the __Required__ checkbox for a parameter without
> providing a default, the pipeline does not trigger if a parameter is not
> present. The difference between this and the preconditions covered earlier is
> that when a precondition isn't met, Spinnaker doesn't even try to run the
> pipeline. However, when a required parameter doesn't exist, Spinnaker tries
> and fails to run a pipeline, surfacing a "Failed Execution" in the UI.

## Passing artifacts

If your pipeline requires artifacts (for example, a Kubernetes manifest file
stored in GCS), you can make this explicit by defining an __Expected Artifact__
and assigning it to the Webhook as shown below:

{%
  include
  figure
  image_path="./artifacts.png"
%}

In order to run this pipeline, you will need to supply the required artifact in
your payload under a list of `artifacts`:

```json
{
  "artifacts": [
    {
      "type": "gcs/object",
      "name": "manifest.yml",
      "reference": "gs://lw-artifacts/manifest.yml"
    }
  ]
}
```
