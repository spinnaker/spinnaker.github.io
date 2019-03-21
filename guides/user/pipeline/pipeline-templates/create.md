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

<!--
## The high-level process

Here's a brief look at the process described in this doc. The detailed process
starts [below](#get-a-pipelines-json).

1. [Get the JSON blob](#get_a_pipelines_json) from an existing pipeline that is close to what your
template will be.

1. Examine the JSON to determine the fields you want to parameterize.

1. Save the pipeline JSON into a file.

1. Edit the file to indicate the variables for the template.

1. Save the JSON as a pipeline template.

1. Make the template available to your team.

-->

## 1. Get a pipeline's JSON

You can create a new pipeline template by using `spin` CLI to get the JSON of
an existing pipeline that is close to what your template will be.

1. [Install `spin` CLI](/guides/spin/cli/), if you haven't already done so.

1. Get the pipeline.

   ```
   spin pipeline get <pipelineName>
   ```

   ...where `<pipelineName>` is the name shown for the pipeline in the Deck UI.

   This returns the pipeline JSON. You'll create a pipeline template from this by
   saving the contents to a file and editing the JSON. You can `tee` it to a file
   from the above command, or you can copy the content, create a new file, and
   paste the content into the new file.

You can also view the pipeline JSON from within the Deck UI, copy it there, and
and paste it into a file.

## 2. Save the pipeline JSON to a file

If you want, you can do this when you first get the pipeline:

```bash
spin pipeline get <pipelineName> | tee new_template.txt
```

## 3. Edit the file for template format

Just by adding a few fields, you can turn this pipeline JSON into
pipeline-template JSON.

The following is the pipeline-template config format. Note the `"pipeline" :`
section; that contains the pipeline JSON, the same as what's in ordinary
pipeline JSON, but referencing any variables that are used. So as you start
with a pipeline blob, you move that entire JSON fragment to the `pipeline`
section.

1. Add a reference to the pipeline templates schema.

   It will always be...

   ```json
   "schema" : "v2",
   ```

1. Declare your variables.

   Add a `variables` section, in which to list all the variables that you
   reference in this template:

   ```json
   "variables" : [
   {
     "type" : "<type>",
     "defaultValue" : <defaultValue>,
     "description" : "<some description>",
     "var1Name" : "<name of this variable>"
   } 
   {
     "type" : "<type>",
     "defaultValue" : <defaultValue>,
     "description" : "<some description>",
     "var2Name" : "<name of this variable>"
   }
     ]
   ```

1. For everything in the `pipeline` section that will be a variable, replace
the value of each item with a SpEL expression that references the variable
declared in `variables`:

   `${ templateVariables.<varName> }`

   For example in a non-templated pipeline, the amount of time to wait in a Wait
   stagewould be represented by...

   `"waitTime" : <time>`

   In our parameterized template, it would be...

   `"waitTime" : "${ templateVariables.timeToWait }",`

   ...where `timeToWait` is a variable already defined in the `variables`
   section of the template.

Here's a complete set of pipeline-template JSON, with the schema, variables
list, and the pipeline definition:

```json
{
  “schema” : “v2”, # Reference to the MPTv2 schema
  “variables” : [
  {
    “type” : “int”,
    “defaultValue” : 42,
    “description” : “The time a wait stage shall pauseth”,
    “name” : timeToWait # This is the name that's referenced in the SpEL expression later
  }
  ],
  “id” : “newSpelTemplate”, # Main identifier to reference this template from instance
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
      “waitTime” : “${ templateVariables.timeToWait }”, # Templated   field.
      “name”: “My Wait Stage”,
      “type” : “wait”,
      “refId” : “wait1”,
      “requisiteStageRefIds”: []
    }
    ]
  }
}
```

## 4. Save the template

```bash
spin pipeline-templates save --file my_template.txt
```

...where `my_template.txt` is the file in which you constructed the template JSON. 

`spin` checks that the file has a reference to the v2 schema and that it has a `pipeline` section.

Spinnaker uses the value of the `id` field in the JSON as the name of the
pipeline template. That's the name you use when you [reference the template
from a pipeline instance](/guides/user/pipeline/pipeline-templates/instantiate/).


## Next steps

* [Parameterize the template](/guides/user/pipeline/pipeline-templates/parameterize/)
* [Distirbute the pipeline template](/guides/user/pipeline/pipeline-templates/distribute/) to your team
* Create a pipeline from the template

