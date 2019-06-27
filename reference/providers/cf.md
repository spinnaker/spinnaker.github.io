---
layout: single
title:  "Cloud Foundry"
sidebar:
  nav: reference
---

{% include alpha version="1.10 and later" %}

{% include toc %}

If you are not familiar with Cloud Foundry (CF) or any of the terms used below, please consult [Cloud Foundry's reference documentation](https://docs.cloudfoundry.org).

## Resource mapping

### Account

In CF, an Account maps to a user account on a CF foundation (where a foundation is a BOSH Director and all the VMs it deploys). This user account is provided via configuration to Spinnaker, and Spinnaker's privileges are determined by the CF user account's permissions; for example, Spinnaker can manage CF apps across all of the [orgs and spaces](https://docs.cloudfoundry.org/concepts/roles.html) which its CF user account can access.

A Spinnaker instance can use multiple CF user accounts to access one or multiple CF foundations.

### Load Balancer

A Spinnaker Load Balancer maps to a CF [route](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html#routes), which is associated with a CF app and does not have a separate resource name. The name of the route is the fully-qualified path, including host, domain, port, and path. A Load Balancer is created as part of a Server Group definition.

Example:

```
<host>.<domain>:<port>/<path>
```

### Server Group

A Spinnaker Server Group maps to a deployment of a CF app in a specific foundation, org, and space. The CF app is named as `APPNAME_STACK_DETAIL_VERSION`, where `APP_NAME` is the app's name in Spinnaker.  If the app was deployed by Spinnaker, the CF app name will also include an appended `-V` with a version number.

When configuring a Server Group, you can either provide a [manifest](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html) for your CF app or enter the parameters directly into the form (direct).

### Region

A Spinnaker Region maps to a CF [space](https://docs.cloudfoundry.org/concepts/roles.html#spaces). The Region is named as "ORG > SPACE", where "ORG" is the name of the CF [org](https://docs.cloudfoundry.org/concepts/roles.html#orgs) and "SPACE" is the name of the CF space.

### Instance

A Spinnaker Server Group Instance maps to a CF app instance.

## Operation mapping

### Deploy

Deploys a CF app (`cf push`). A deployment of a Server Group in Spinnaker causes a new CF app deployment.

### Destroy

Deletes a CF app (`cf delete`). Deletion of a Server Group in Spinnaker causes deletion of a CF app.

### Resize

Scales a CF app up or down (`cf scale`).

### Enable

Starts a CF app (`cf start`). Enabling a Server Group in Spinnaker causes a stopped CF app to start.

### Disable

Stops a CF app (`cf stop`). Disabling a Server Group in Spinnaker causes a CF app to stop.

### Rollback

Starts the previous version of the Server Group (`cf start`) and disables the current running Server Group (`cf stop`).

### Terminate Instance

Restarts a CF app instance. In CF, "Terminate Instance" is index-based. In the Spinnaker Server Group Instance name, the last digit is the CF [app instance index](https://docs.run.pivotal.io/devguide/deploy-apps/environment-variable.html#CF-INSTANCE-INDEX).

### Load Balancer Create

A Load Balancer is created as part of a Server Group definition.

### Load Balancer Delete

Deletes a CF route.

## See Also
[Cloud Foundry specific Pipeline Stages](/reference/pipeline/stages/#cloud-foundry)