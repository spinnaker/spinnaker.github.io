---
layout: single
title:  "Create a Pipeline from a Template"
sidebar:
  nav: guides
---

{% include toc %}

Given a pipeline template that defines variables to be resolved per pipeline,
you can create pipelines that reference that template and that provide values
for all of those variables.

## Instantiate a pipeline

1. Get the pipeline template.

    `spin pipeline-template list`

    This returns a list of all pipeline templates avaialble in the Spinnaker
    deployment.

1. From the list, determine which of the listed templates is the one you want,
and get it using the following command:

   `spin pipeline-template get --id <pipelineTemplateId>`

   This outputs the JSON content of the template. You can save it in a file, or
   just examine it so that you know what you're implementing.

1. Create a file, which will contain the JSON for the pipeline.

   Use the following format:

   ```json
   {
     "schema": "v2",
     "application": "myApp", # Set this to the app you want to create the pipeline in.
     "name": "<pipeline name>", # Pipeline name, remember this for the next part.
     "template": {
       "artifactAccount": "front50ArtifactCredentials", # Static constant
       "reference": "spinnaker://newSpelTemplate", # Reference to the pipeline template we published above. We saved it in Spinnaker, so we prefix the template id with ‘spinnaker://’.
       "type": "front50/pipelineTemplate", # Static constant
     },
     "variables": {
       "waitTime": 4 # Value for the template variable.
     },
     "exclude": [],
     "triggers": [],
     "parameters": [],
     "notifications": [],
     "description": "",
     "stages": []
   }
   ```

   Make sure the content of the file includes, at the beginning, the `schema: v2,` reference.

1. Add a reference to the pipeline template:

   In the `template` element, add a reference to the specific template, using
   the following format:

   ```json
   "template": {
     "artifactAccount": "front50ArtifactCredentials", # Static constant
     "reference": "spinnaker://<templateId>",
     "type": "front50/pipelineTemplate" # Static constant
   }
   ```
   
   Because the template was "saved," using `spin pipeline-template save`, it
   was added to the Spinnaker deployment and is available using `spinnaker://`.

## Provide values for the variables

> Note: the variables [defined in the pipeline
> template](/guides/user/pipeline/pipeline-templates/create/#3-edit-the-file-for-template-format)
> include default values, so you don't have to provide a value for every variable defined.

In the pipeline JSON file, in the `variables` section, list each variable
for which you're providing values, and write that value.

   Use the following format:

   ```json
   "variables": {
     "varName": <value>
     "otherVarName": <its_value>
   }
   ```
You can code each value by hand in the pipeline JSON that you create. You can
also generate the JSON and populate the values programatically. For simplicity
This doc describes doing it by hand.


## Specify inheritance and overrides

1. [Indicate which elements of the template you want to
inherit](/guides/user/pipeline/pipeline-templates/override/).

   By default, the pipeline instance inherits the stages, expected artifacts, triggers, parameters, and notifications from the template.
   It's possible to opt out of inheriting triggers, parameters, and notifications by including the corresponding string in the `exclude` element.
   For example, the template might have a trigger defined in the `triggers` element, but you can opt out of inheriting it by including `triggers` inside the `exclude` element.

1. If you want, you can
[override](/guides/user/pipeline/pipeline-templates/override/) elements in the
template.

## Add new stages

Create a new stage by adding the stage spec to the pipeline JSON.

Include an `inject` element, indicating the stage's position by identifying
which stage this new stage comes after.

In the example below, the new stage `wait0` is injected after the `wait2`
stage.

```json
"stages": [
    {
        "refId": "wait2",
        "type": "wait",
        "config": {
            "waitTime": 67
        }
    },
    {
        "refId": "wait0",
        "inject": {
            "after": ["wait2"]
        },
        "type": "wait",
        "config": {
            "waitTime": 2
        }
    }
]
```

## Add a branch to the pipeline

The template you're using might itself have branches, but if it doesn't, and
you want your pipeline instance to have a branch, inject new stages as
described [above](#add-new-stages), but include multiple `before` or multiple
`after` elements (or both) to describe the graph. 

## Save the pipeline

`spin pipeline save --file <path to pipeline json>`
