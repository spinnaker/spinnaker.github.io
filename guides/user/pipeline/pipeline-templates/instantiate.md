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

## Provide values for the variables

> Note: the variables [defined in the pipeline
> template](/guides/user/pipeline/pipeline-templates/create/#3-edit-the-file-for-template-format)
> include default values, so you don't have to provdide a value for every variabled defined.

You can code each value by hand in the pipeline JSON that you create. You can
also generate the JSON and populate the values programatically. For simplicity
This doc describes doing it by hand.

