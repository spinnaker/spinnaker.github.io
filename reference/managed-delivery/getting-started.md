---
layout: single
title:  "Getting Started"
sidebar:
  nav: reference
---

{% include toc %}

You'll be interacting with Spinnaker's Managed Delivery using curl and the Spinnaker api for now.

Spinnaker accepts resource definitions in `yaml` and in `json`.


### Env Setup
```bash
# env setup
SPIN_URL="http://spinnaker-api/resources"
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

### Future

There are great plans and ambitions for better tooling. 
Please look forward to that.
