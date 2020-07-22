---
layout: single
title:  "Manage Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

## Overview

Once you have `spin` install and configured, you can use it to start
managing your managed pipeline templates (MPT). Note that currently only v2
pipeline templates are supported from `spin`.

`spin` can manage the whole lifecycle of your v2 pipeline templates:

```bash
$ spin pipeline-templates

Usage:
   pipeline-template [command]

Aliases:
  pipeline-template, pipeline-templates, pt

Available Commands:
  delete      Delete the provided pipeline template
  get         Get the pipeline template with the provided ID
  list        List the pipeline templates for the provided scopes
  plan        Plan the provided pipeline template config
  save        Save the provided pipeline

Flags:
  -h, --help   help for pipeline-template

Global Flags:
      --config string          path to config file (default $HOME/.spin/config)
      --gate-endpoint string   Gate (API server) endpoint (default http://localhost:8084)
  -k, --insecure               ignore certificate errors
      --no-color               disable color (default true)
      --output string          configure output formatting
  -q, --quiet                  squelch non-essential output

Use " pipeline-template [command] --help" for more information about a command.
```

The following assumes Spinnaker is running and Gate is
listening on `http://localhost:8084`. If gate is running elsewhere,
you can set the Gate endpoint with the global `--gate-endpoint` flag.

## Managing Your Pipeline Template's Lifecycle

### Create and update pipeline templates with `save`

```bash
$ spin pipeline-templates save --file <path to pipeline json>

Pipeline template save succeeded
```

Note that `save` accepts the pipeline template in JSON format. You can quickly export an
existing pipeline template into a valid argument to the `--file` flag by using the `get` command.

### List pipeline templates for a set of scopes with `list`

```bash
spin pipeline-templates list --scopes app1,app2
# Note: --scopes is optional, by default all pipeline templates are global.

[
...
{
  "id": "myPipelineTemplate"
  "pipeline": {...}
  ...
}
...
]

```

### Retrieve a single pipeline template with `get`

```bash
spin pipeline-templates get --id myPipelineTemplate
{
  "id": "myPipelineTemplate"
  "pipeline": {...}
}
```

### Visualize a hydrated pipeline with `plan`

```bash
spin pipeline-templates plan --file <path to pipeline config>

{
  "application": "my-spinnaker-app"
  "stages": [...] # Evaluated pipeline config based on template config values.
}
```

### Delete a pipeline template with `delete`

```bash
spin pipeline-template delete myPipelineTemplate

Pipeline template deleted
```
