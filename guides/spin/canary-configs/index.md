---
layout: single
title:  "Manage Canary Configs"
sidebar:
  nav: guides
---

{% include toc %}

## Overview

You can use `spin` to manage the whole lifecycle of your canary configs:

```bash
$ spin canary canary-configs
Usage:
   canary canary-config [command]

Aliases:
  canary-config, canary-configs, cc

Available Commands:
  delete      Delete the provided canary config
  get         Get the canary config with the provided id
  list        List the canary configs
  retro       Retro the provided canary config
  save        Save the provided canary config

Flags:
  -h, --help   help for canary-config

Global Flags:
      --config string            path to config file (default $HOME/.spin/config)
      --default-headers string   configure default headers for gate client as comma separated list (e.g. key1=value1,key2=value2)
      --gate-endpoint string     Gate (API server) endpoint (default http://localhost:8084)
  -k, --insecure                 ignore certificate errors
      --no-color                 disable color (default true)
      --output string            configure output formatting
  -q, --quiet                    squelch non-essential output

Use " canary canary-config [command] --help" for more information about a command.
```

The following instructions assume Spinnaker is running and Gate is listening on `http://localhost:8084`. If
gate is running elsewhere, you can set the Gate endpoint with the global `--gate-endpoint` flag.


## Create and update canary configs with `save`

```bash
$ spin canary canary-configs save --file <path to canary config json>
```

Note that `save` accepts the canary config in JSON format. You can quickly export an existing
canary config into a valid argument to the `--file` flag by using the `get` command.

## List canary configs with `list`

```bash
spin canary canary-config list

[
...
{
  "id": "canaryConfigId",
  "name": "canaryConfigName"
  ...
},
...
]

```

## Retrieve a single canary config with `get`

```bash
spin canary canary-config get canaryConfigId
{
  "id": "myPipelineTemplate"
  ...
}
```

## Delete a canary config with `delete`

```bash
spin canary canary-config delete canaryConfigId
```

## Test a canary config with `retro`

The `retro` command runs a retrospective analysis given a canary config. You must also supply the
control and experiment group locators and analysis time window.

```$bash
$ spin canary canary-configs retro \
  -f <path to canary config json>
  --control-group app-control-v001 --control-location us-central1 \
  --experiment-group app-experiment-v001 --experiment-location us-central1 \
  --start 2019-09-17T16:27:19.867Z \
  --end 2019-09-17T17:27:19.867Z

Initiating canary execution for supplied canary config
Spawned canary execution with id 01DR9BEP8XTJQDPVFJ41C9MBJ6, polling for completion...
Retrospective canary execution finished, judgement = PASS
```
