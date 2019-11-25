---
layout: single
title:  "Getting Started"
sidebar:
  nav: reference
---

{% include toc %}

UI and version control support for Managed Delivery are currently limited, so you'll be interacting with Managed Delivery using `curl` and the Spinnaker API for most operations.

Spinnaker accepts resource definitions in `yaml` and in `json`.


### Env Setup
```bash
# env setup
SPIN_URL="http://spinnaker-api/managed/resources"
SPINNAKER_USER="${USER}@email"

```


### Create or Update a Resource

To submit a resource to Spinnaker, save your configration in a file (`resource.yml`).

TODO: an example

Then, submit it to Spinnaker:

```bash
curl -X PUT -H "Content-Type: application/x-yaml" --header "X-SPINNAKER-USER: ${SPINNAKER_USER}" --data-binary @$file ${SPIN_URL}
```

### Delete a resource

To delete a resource, send a delete request to Spinnaker:

```bash
curl -X DELETE -H "Content-Type: application/x-yaml" --header "X-SPINNAKER-USER: ${SPINNAKER_USER}" ${SPIN_URL}/resourceName
```

### Find a Resource's ID
For some API calls you need the resource ID. You can find this by clicking on the resource in the UI, and then clicking on Resource Actions -> Raw Source (right side on the panel that pops out). The ID will be in the the metadata section and will be human readable, like ec2:cluster:test:keeldemo-main.

### Future

There are great plans and ambitions for better tooling. 
Please look forward to that.
