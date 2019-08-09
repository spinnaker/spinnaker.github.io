---
layout: single
title:  "Pipeline Templates"
sidebar:
  nav: reference
---

{% include toc %}

## Pipeline template JSON

A pipeline template uses the following config JSON:

```json
{
  "schema": "v2",
  "variables": [
    {
      "type": "<type>",
      "defaultValue": <value>,
      "description": "<description>",
      "name": "<varName>"
    }
  ],
  "id": "<templateName>",           # The pipeline instance references the template using this
  "protect": <true | false>,
  "metadata": {
    "name": "displayName",          # The display name shown in Deck
    "description": "<description>",
    "owner": "example@example.com",
    "scopes": ["global"]            # Not used
  },
  "pipeline": {                     # Contains the templatized pipeline itself
    "lastModifiedBy": "anonymous",  # Not used
    "updateTs": "0",                # Not used
    "parameterConfig": [],          # Same as in a regular pipeline
    "limitConcurrent": true,        # Same as in a regular pipeline
    "keepWaitingPipelines": false,  # Same as in a regular pipeline
    "description": "",              # Same as in a regular pipeline
    "triggers": [],                 # Same as in a regular pipeline
    "notifications": [],            # Same as in a regular pipeline
    "stages": [                     # Contains the templated stages
      {
        # This one is an example stage:
        "waitTime": "${ templateVariables.waitTime }",  # Templated field.
        "name": "My Wait Stage",
        "type": "wait",
        "refId": "wait1",
        "requisiteStageRefIds": []
      }
    ]
  }
}
```

## Pipeline JSON

A pipeline instance that implements a pipeline template uses the following
config:

```json
{
  "schema": "v2",
  "application": "<appName>",     # Set this to the app you want to create the pipeline in.
  "name": "New Pipeline Name",    # The name of your pipeline.
  "template": {
    "type": "front50/pipelineTemplate",
    "artifactAccount": "front50ArtifactCredentials",
    "reference": "spinnaker://<templateName>"   # The `id` field from the pipeline template.
                                                # Assuming the template was saved in Spinnaker,
                                                # you can prefix the id with ‘spinnaker://’.
  },
  "variables": {
    "<varName>": <value>,         # Value for the template variable.
    "someOtherVar": <value>
  },
  "inherit": [],
  "triggers": [],
  "parameters": [],
  "notifications": [],
  "description": "",
  "stages": []
}
```

In `.template` section, `http://` and `file://` prefixes are also supported.
