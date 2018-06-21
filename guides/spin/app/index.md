---
layout: single
title:  "Manage Applications"
sidebar:
  nav: guides
---

{% include toc %}

## Overview

Once you have `spin` [installed and configured](/guides/spin/cli), you can use it to manage
your Spinnaker application's lifecycle.

`spin` can manage the whole lifecycle of your application:

```bash
# NOTE: You can inspect any command with the `--help` flag.
$ spin application --help

This command is accessed by using one of the subcommands below.

Subcommands:
    delete    Delete the specified application.
    get       Get the specified application.
    list      List all applications.
    save      Save the provided application.
```

The following assumes Spinnaker is running and Gate is
listening on `http://localhost:8084`. If gate is running elsewhere,
you can set the Gate endpoint with the global `--gate-endpoint` flag.

## Managing Your Application's Lifecycle

### Create a new application using `save`

```bash
$ spin application save --application-name my-app --owner-email someone@example.com --cloud-providers "gce, kubernetes"

Application save succeeded
```

Applications can also be updated with the `save` command.

### List our Spinnaker applications with `list`

```bash
spin application list
[
...
{
  "accounts": "my-account",
  "cloudProviders": "gce,kubernetes",
  "createTs": "1529349914747",
  "email": "jacobkiefer@google.com",
  "instancePort": 80,
  "lastModifiedBy": "anonymous",
  "name": "my-app",
  "platformHealthOnly": true,
  "providerSettings": {
    "gce": {
    "associatePublicIpAddress": true
    }
},
"updateTs": "1529349915014",
"user": "anonymous"
}
...
]
```

We see our application in the returned list along with the other existing
applications.

### Retrieve a single application with `get`

```bash
spin application get my-app
{
  "attributes": {
    "accounts": "my-account",
    "cloudProviders": "gce,kubernetes",
    "createTs": "1529349914747",
    "email": "jacobkiefer@google.com",
    "instancePort": 80,
    "lastModifiedBy": "anonymous",
    "name": "my-account",
    "platformHealthOnly": true,
    "providerSettings": {
      "gce": {
        "associatePublicIpAddress": true
      }
    },
    "updateTs": "1529349915014",
    "user": "anonymous"
  },
  "clusters": {
    "my-account-cluster": [
      {
        "loadBalancers": [],
        "name": "my-account-gce",
        "provider": "gce",
        "serverGroups": [
          "my-account-gce-v000",
          "my-account-gce-v001"
        ]
      }
    ]
  },
  "name": "my-account"
}

```

Note that we retrieve not only the application attributes, but also the clusters
associated with the application.

### Delete a single application with `delete`

When we're finished with our Spinnaker application, we can delete it.

```bash
spin application delete --application-name my-app
```
