---
layout: single
title:  "Manage Pipelines"
sidebar:
  nav: guides
---

{% include toc %}

## Overview

Once you have `spin` install and configured, you can use it to start
managing your Spinnaker pipelines.

`spin` can manage the whole lifecycle of your pipeline:

```bash
# NOTE: You can inspect any command with the `--help` flag.
$ spin pipeline --help

This command is accessed by using one of the subcommands below.

Subcommands:
    delete     Delete the provided pipeline.
    execute    Execute the provided pipeline.
    get        Get the pipeline with the provided name from the provided pipeline.
    list       List the pipelines for the provided pipeline.
    save       Save the provided pipeline.

```

The following assumes Spinnaker is running and Gate is
listening on `http://localhost:8084`. If gate is running elsewhere,
you can set the Gate endpoint with the global `--gate-endpoint` flag.

## Managing Your Pipeline's Lifecycle

### Create and update pipelines with `save`

```bash
$ spin pipeline save --file <path to pipeline json>

Parsed submitted pipeline: <...>

Pipeline save succeeded
```

Note that `save` accepts pipeline in JSON format. You can quickly export an
existing pipeline into a valid argument to the `--file` flag by using the `get` command.
You can also export pipeline JSON from the pipeline UI in Deck by clicking
`Pipeline Actions > Edit as JSON` and copying the JSON contents, e.g.

{% include figure
   image_path="./edit-json.png"
%}

You can also template the pipeline JSON using your favorite templating engine.

### List pipelines in an application with `list`

```bash
spin application list --application my-app

[
...
{
  "application": "my-app"
  ...
}
...
]

```

### Retrieve a single pipeline with `get`

Get a single pipeline with `get`:

```bash
spin pipeline get --name my-pipeline --application my-app
{
  "application": "my-app"
  "stages": [...]
}
```

### Start a pipeline execution with `execute`

Start a pipeline execution with `execute`:

```bash
spin pipeline execute --name my-pipeline --application my-app

Pipeline execution started
```

### Delete a pipeline with `delete`

```bash
spin pipeline delete --name my-pipeline --application my-app

Pipeline deleted
```
