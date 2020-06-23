---
layout: single
title:  "API"
sidebar:
  nav: guides
redirect_from: /reference/managed-delivery/api/
---

{% include toc %}


The endpoints for managed delivery are located in the `managed-controller`.
The endpoints are easily accessible from the swagger api page of your Spinnaker instance.

This doc provides samples for how to use the endpoints.


### Export an Existing Resource

The export endpoint (under the "managed-controller") allows you to take an existing resource and export it to a yaml config.

`GET 
/managed/resources/export/{cloudProvider}/{account}/{type}/{name}?serviceAccount=yourServiceAccount@company.com`

These definitions can be stored in your git repo.


### Validating yaml
 
The ad-hoc diff endpoint allows you to see if a resource config is valid, and to see the difference between config (desired state) and reality.

`POST /managed/resources/diff -d "{YOUR_RESOURCE_CONFIG}"`

If the resource configuration is valid you'll see information returned about the resource, like whether or not there is a diff, what the diff is, and what the resource name will be.
If the resource configuration is invalid you'll see an error and some text indicating what is wrong about the schema.  


### Viewing a Resource

The UI will show a flag on each resource that is declaratively managed. 
If you click on the resource, you can view its definition (raw source)


If you'd rather hit the api directly, you can refer to the UI for the resource name, or the logs for the publish stage. 

```bash
GET /managed/resources/{name}
```

### Viewing a Resource History

Spinnaker will take actions to make sure that your resource matches what you've defined. 
To view those actions in a list you can hit the `history` endpoint:

```bash
GET /history/{name}
```

This endpoint shows you why an action was taken on a resource, and what that action was.
Soon there will be a nicer UI for this.