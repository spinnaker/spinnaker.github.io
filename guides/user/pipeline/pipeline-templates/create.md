---
layout: single
title:  "Create a Pipeline Template"
sidebar:
  nav: guides
---

{% include toc %}

This document describes how to create a pipeline template from an existing
pipeline, and how to parameterize that template.

When you create a pipeline template, you start with the underlying JSON of a
pipeline that already resembles the template you want. You turn this JSON into
template JSON.

## The high-level process

1. [Get the JSON blob](#get_a_pipelines_json) from an existing pipeline that is close to what your
template will be.

  If necessary, create a new pipeline for this purpose.

1. Examine the JSON to determine the fields you want to parameterize.

   That is, see which fields in the pipeline JSON will become variables in the
   ensuing pipeline template. A pipeline template variable is a field whose
   value will differ per instantiation&mdash;each pipeline created based on the
   template. 

1. Save the pipeline JSON into a file.

1. Edit the file to indicate the variables for the template.

   You'll define all the variables in the `"Variables"` section, and reference those variables in the
   `"stages"` section.

1. Save the JSON as a pipeline template.

1. Make the template available to your team

## Get a pipeline's JSON

You can create a new pipeline template by using `spin` CLI to get the JSON of
an existing pipeline that is close to what your template will be.


```
spin pi get <pipelineName>
```

...where `<pipelineName>` is the name shown for the pipeline in the Deck UI.

This returns the pipeline JSON. You'll create a pipeline template from this by
saving the contents to a file and editing the JSON. You can `tee` it to a file
from the above command, or you can copy the content, create a new file, and
paste the content into the new file.

You can also view the pipeline JSON from within the Deck UI, copy it there, and
and paste it into a file.

## Determine what your variables will be


## Save the pipeline JSON to a file

If you want, you can do this when you first get the pipeline:

```
spin pi get <pipelineName> | tee new_template.txt
```

## Edit the file to make it a template

Just by adding a few fields, you can turn this pipeilne JSON into pipeline-template JSON:

The following is the pipeline-template config format. Note the `"pipeline" :`
section; that contains the pipeline JSON, so as you start with a pipeline blob,
you move that entire JSON fragment to the `pipeline` section.

```json
{
  “schema” : “v2”,
  “variables” : [
  {
    “type” : “int”,
    “defaultValue” : 42,
    “description” : “The time a wait stage shall pauseth”,
    “name” : “waitTime”
  }
  ],
  “id” : “newSpelTemplate”, # Main identifier to reference this   template
  “protect” : false,
  “metadata” : {
    “name” : “Variable Wait”,
    “description” : “A demonstrative Wait Pipeline.”,
    “owner” : “example@example.com”,
    “scopes” : [“global”]
  },
  “pipeline”: { # A “normal” pipeline definition.
    “lastModifiedBy” : “anonymous”,
    “updateTs” : “0”,
    “parameterConfig” : [],
    “limitConcurrent”: true,
    “keepWaitingPipelines”: false,
    “description” : “”,
    “triggers” : [],
    “notifications” : [],
    “stages” : [
    {
      “waitTime” : “${ templateVariables.waitTime }”, # Templated   field.
      “name”: “My Wait Stage”,
      “type” : “wait”,
      “refId” : “wait1”,
      “requisiteStageRefIds”: []
    }
    ]
  }
}
```

## Parameterize the template

In the file, now containing the JSON of the original pipeline, identify which
values should be variables. 


## Save the template


## Next steps

* Distirbute the pipeline template to your team
* Create a pipeline from the template

