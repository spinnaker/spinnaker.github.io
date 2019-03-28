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
     “schema”: “v2”,
     “application”: “myApp”, # Set this to the app you want to create the pipeline in.
     “name”: “<pipeline name>”, # Pipeline name, remember this for the next part.
     “template”: {
       “source”: “spinnaker://newSpelTemplate” # Reference to the pipeline template we published above. We saved it in Spinnaker, so we prefix the template id with ‘spinnaker://’. ‘http://’ and ‘file://’ prefixes are also supported.
     },
     “variables”: {
       “waitTime”: 4 # Value for the template variable.
     },
     “inherit”: [],
     “triggers”: [],
     “parameters”: [],
     “notifications”: [],
     “description”: “”,
     “stages”: []
   }
   ```

   Make sure the content of the file includes, at the beginning, the `"schema": "v2",` reference.

1. Add a reference to the pipeline template:

   For the `"template"` field, add a reference to the specific template, using
   the following format:

   ```json
   "template": {
   	 "source": "spinnaker://<templateName>"
   }
   ```
   
   Because the template was "saved," using `spin pipeline-template save`, it's
   added to the Spinnaker deployment and is available using `spinnaker://`.

## Provide values for the variables

> Note: the variables [defined in the pipeline
> template](/guides/user/pipeline/pipeline-templates/create/#3-edit-the-file-for-template-format)
> include default values, so you don't have to provdide a value for every variabled defined.

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

   By default, the pipeline instance inherits the stages from `pipeline.stages`
   only. Anything else you want to inherit, from inside `pipeline` you have to 
   identify explicitly. For example, the template might have a trigger defined
   in the `"triggers"` element, but that trigger is not used in your pipeline
   unless you include `"triggers"` inside the `"inherit"` element.

1. If you want, you can
[override](/guides/user/pipeline/pipeline-templates/override/) elements in the
template.


## Save the pipeline

`spin pipeline save --file <path to pipeline json>`

