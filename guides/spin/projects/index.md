---
layout: single
title:  "Manage Projects"
sidebar:
  nav: guides
---

{% include toc %}

## Overview

Once you have `spin` installed and configured, you can use it to start
managing your Spinnaker project dashboards as code.

`spin` can manage the whole lifecycle of your projects:

```bash
$ spin project
Usage:
   project [command]

Aliases:
  project, prj

Available Commands:
  delete        Delete the provided project
  get           Get the config for the specified project
  get-pipelines Get the pipelines for the specified project
  list          List the all projects
  save          Save the provided project

Flags:
  -h, --help   help for project

Global Flags:
      --config string            path to config file (default $HOME/.spin/config)
      --default-headers string   configure default headers for Gate client as comma separated list (e.g. key1=value1,key2=value2)
      --gate-endpoint string     Gate (API server) endpoint (default http://localhost:8084)
  -k, --insecure                 ignore certificate errors
      --no-color                 disable color (default true)
  -o, --output string            configure output formatting
  -q, --quiet                    squelch non-essential output

Use " project [command] --help" for more information about a command.
```

The following assumes Spinnaker is running and Gate is
listening on `http://localhost:8084`. If Gate is running elsewhere,
you can set the Gate endpoint with the global `--gate-endpoint` flag.

## Managing your project's lifecycle

### Create and update projects with `save`

```bash
$ spin project save --file <path to project json>

Project save succeeded
```

Note that `save` accepts project in JSON format. You can quickly export an
existing project into a valid argument to the `--file` flag by using the `get` command.

You can also template the pipeline JSON using your favorite templating engine.
A demo of creating projects via spinnaker's jsonnet library, sponnet, can be seen here:
https://github.com/spinnaker/sponnet/tree/master/demo#sponnet-demo

### List projects `list`

```bash
spin project list

[
 {
  "config": {
   "applications": [...],
   "clusters": [...],
   "pipelineConfigs": [...]
  },
  ...
 }
]
```

### Retrieve a single project with `get`

Get a single project with `get`:

```bash
spin project get <project name>
{
"config": {
 "applications": [...],
 "clusters": [...],
 "pipelineConfigs": [...]
  }
...
}
```

### Get a project's pipelines with `get-pipelines`

Get a project's pipelines with `get-pipelines`:

```bash
spin project get-pipelines <project name>

{
  "application": "my-app"
  "stages": [...]
}
```

### Delete a project with `delete`

```bash
spin project delete --name <project name>

Project deleted
```
