---
layout: single
title:  "Cloud Foundry"
sidebar:
  nav: reference
---

{% include toc %}

If you are not familiar with Cloud Foundry (CF) or any of the terms used below, please consult [Cloud Foundry's reference documentation](https://docs.cloudfoundry.org).

## Resource mapping

### Account
In CF, an account maps to a user account on a CF foundation. This user account is provided via configuration to Spinnaker, and Spinnaker’s privileges are determined by the account’s permissions; for example, Spinnaker can manage apps across all of the orgs and spaces which its account can access.

A Spinnaker instance can use multiple CF accounts to access one or multiple CF foundations.

### Load Balancer
A Spinnaker load balancer maps to a CF route, which is associated with an app and does not have a separate resource name. The name of the route is the fully-qualified path, including host, domain, port, and path. A load balancer is created as part of a Server Group definition.

Example:

```
<host>.<domain>:<port>/<path>
```

### Server Group
A Spinnaker server group maps to a deployment of a CF app in a specific foundation, org, and space. The server group is named as `APPNAME_STACK_DETAIL_VERSION`, where `<APP_NAME>` is the CF app name.  If the app was deployed by Spinnaker, the server group name will include an appended `-V` with a version number.

When configuring a server group, you can either provide a manifest for your app or enter the parameters directly into the form (direct).

### Region

A Spinnaker region maps to a CF space. The region is named as "ORG > SPACE", where "ORG" is the name of the CF org and "SPACE" is the name of the CF space.

### Instance
A Spinnaker server group instance maps to a CF app instance.

## Operation mapping

### Deploy
Deploys a CF application (`cf push`). A deployment of a server group in Spinnaker causes a new CF app deployment.

### Destroy
Deletes a CF application (`cf delete`). Deletion of a server group in Spinnaker causes deletion of a CF app.

### Resize
Scales a CF app up or down (`cf scale`).

### Enable
Starts a CF application (`cf start`). Enabling a server group in Spinnaker causes a stopped CF app to start.

### Disable
Stops a CF app (`cf stop`). Disabling a server group in Spinnaker causes a CF app to stop.

### Rollback
Disables the current running server group (`cf stop`) and starts the previous version of the server group (`cf start`).

### Terminate Instance
Restarts a CF app instance. In CF, "Terminate Instance" is index-based. In the Spinnaker server group instance name, the last digit is the CF app instance index.

### Load Balancer Create
A load balancer is created as part of a server group definition.

### Load Balancer Delete
Deletes a CF route.
