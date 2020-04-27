---
layout: single
title:  "Resource Status"
sidebar:
  nav: guides
redirect_from: /reference/managed-delivery/resource-status/
---

{% include toc %}

💡 *If you're not sure what a managed resource is, check out our [overview of Managed Delivery](/guides/user/managed-delivery) first.*

## Overview
Managed resources always have a **status**, which describes the current state of the resource from Spinnaker's perspective. A resource's status can help you quickly answer questions like:
  - Is Spinnaker taking automatic action on this resource right now?
  - Does the actual state of this resource match the declarative configuration I gave to Spinnaker?
  - Is something wrong with this resource?

## How to find a resource's status

### UI
On the Infrastructure views (Clusters, Load Balancers, Firewalls), you'll see a color-coded "M" logo attached to any resources that are managed by Spinnaker. Hovering over the logo reveals additional context about the current status and what it means.

Example on a cluster:
{%
  include
  figure
  image_path="./cluster-resource-status-ui.png"
%}


### API
Find the [ID of a resource](/guides/user/managed-delivery/getting-started/#find-your-resource-id) and call the `/managed/resources/<resourceId>/status` endpoint.

Example request:
```bash
curl -X GET --header "X-SPINNAKER-USER: ${SPINNAKER_USER}" "${SPIN_URL}/<resourceId>/status"
```
Example response:
```json
{ "status": "HAPPY" }
```

## Status Reference

### Created
{%
  include
  figure
  image_path="./resource-status-created.png"
%}

When a resource has this status, it means Spinnaker has just received the resource’s declarative configuration and hasn't taken any action yet.

If the actual state of the resource matches the declarative configuration, the resource will transition to the [Happy](/guides/user/managed-delivery/resource-status/#happy) status the next time Spinnaker checks it.

If Spinnaker detects a drift from the declarative configuration in the future, the resource will change status to [Diff](/guides/user/managed-delivery/resource-status/#diff). Once Spinnaker starts taking automatic action to correct the drift, the status will change to [Actuating](/guides/user/managed-delivery/resource-status/#actuating).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Diff
{%
  include
  figure
  image_path="./resource-status-diff.png"
%}

When a resource has this status, it means Spinnaker detected a drift from the declarative configuration but hasn't taken any action yet.

Once Spinnaker starts taking automatic action to correct the drift, the status  changes to [Actuating](/guides/user/managed-delivery/resource-status/#actuating).

While Spinnaker is managing a resource, manual changes made via the UI or the API are automatically reversed ("stomped") in favor of the declarative configuration.

### Actuating
{%
  include
  figure
  image_path="./resource-status-actuating.png"
%}

When a resource has this status, it means Spinnaker detected a drift from the declarative configuration and automatic action is in progress to resolve it. You can click on "History" to see details about the detected drift and the specific tasks Spinnaker launched, along with whether they succeeded or failed.

If automatic actions successfully resolve the drift, the status will change to [Happy](/guides/user/managed-delivery/resource-status/#happy). If automatic actions don't help to resolve the drift, the status will change to [Unhappy](/guides/user/managed-delivery/resource-status/#unhappy).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Happy
{%
  include
  figure
  image_path="./resource-status-happy.png"
%}

When a resource has this status, all is well and the actual state of the resource matches its declarative configuration.

If Spinnaker detects a drift from the declarative configuration in the future, the resource status will change to [Diff](/guides/user/managed-delivery/resource-status/#diff). Once Spinnaker starts taking automatic action to correct the drift, the status will change to [Actuating](/guides/user/managed-delivery/resource-status/#actuating).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Unhappy
{%
  include
  figure
  image_path="./resource-status-unhappy.png"
%}

When a resource has this status, it means Spinnaker detected a drift from the declarative configuration but hasn't been able to resolve it through automatic actions. This might mean that the actions Spinnaker has taken are failing, or something else is preventing the actions from having their desired effect.

While a resource is Unhappy, Spinnaker will continue trying to resolve the drift and may eventually succeed. If it does, the resource will transition to the [Happy](/guides/user/managed-delivery/resource-status/#happy) status.

You can click on "History" to see the detected drift along with actions Spinnaker is taking. If you decide manual intervention is needed to remedy any issues you might discover, you can temporarily pause management by clicking "Pause management of this resource" or by pausing the entire application on the Config view for your app.

### Paused
{%
  include
  figure
  image_path="./resource-status-paused.png"
%}

When a resource has this status, it means Spinnaker is configured to continuously manage the resource but you've chosen to temporarily pause management. While management is paused Spinnaker won't check for drift from the declarative configuration, and it won't take any automatic actions. Depending on whether you've paused the specific resource or the entire application, you can either click "Resume management of this resource" or go to the Config view in your app to resume management.

When you resume management the status will change to [Resumed](/guides/user/managed-delivery/resource-status/#resumed).

### Resumed
{%
  include
  figure
  image_path="./resource-status-resumed.png"
%}

When a resource has this status, it means management was just resumed after being temporarily paused and Spinnaker hasn't checked for drift from the declarative configuration yet.

If a drift is detected, the status will change to [Diff](/guides/user/managed-delivery/resource-status/#diff). If no drift is detected, the status will change to [Happy](/guides/user/managed-delivery/resource-status/#unhappy).

### Currently unresolvable
{%
  include
  figure
  image_path="./resource-status-currently-unresolvable.png"
%}

When a resource has this status, it means something Spinnaker requires to properly manage the resource is either not ready yet or temporarily experiencing disruption. Automatic action won't be taken while in this status, but it doesn't necessarily mean something is broken. Some examples of things that might lead to a resource entering this status:

  - A downstream system (like a container registry or cloud provider) temporarily rate limiting or experiencing availability issues
  - A required part of the resource's desired state (like a VM image) not being available yet

If you see this status and want to investigate the cause, you can click "History" to view additional details and understand what else was happening when the issue began. While you may decide to take some action as a result of this status, it's unlikely the issue requires manual intervention. Once the issue is resolved the resource will transition to whatever status is applicable at the time based on its desired state.

### Error
{%
  include
  figure
  image_path="./resource-status-error.png"
%}

When a resource has this status, it means something went wrong while trying to check the resource for drift from its declarative configuration. Because something went wrong, Spinnaker can't take automatic actions and drift from the declarative configuration won't be resolved (until something changes). Some examples of problems that might lead to an error status:

  - A problem retrieving or processing information about the current state of the resource
  - A problem with the declarative configuration (invalid settings, etc.)
  - A bug or issue with Spinnaker itself

After an error, Spinnaker will continue trying to check the resource and may eventually succeed. If it does, the resource will transition to whatever status is applicable at that time.

If you see this status, it's probably best to investigate the current state of the resource manually and double check that nothing is broken. You can start by clicking "History" to see the details of the error and what else was happening when the error occurred. If you decide manual intervention is needed to remedy any issues you might discover, you can temporarily pause management by clicking "Pause management of this resource".

### Unknown
{%
  include
  figure
  image_path="./resource-status-unknown.png"
%}

When a resource has this status, it means Spinnaker was unable to determine the current status for some reason. Because the status is unknown, it's tough to tell by the status alone whether something is *wrong*, or just unexpected.

After encountering this status, Spinnaker will continue trying to check the resource for its status and may eventually succeed. If it does, the resource will transition to whatever status is applicable at that time.

If you see this status, it's probably best to investigate the current state of the resource manually and double check that nothing is broken. You can start by clicking "History" to see details about what's been happening with the resource recently. If you decide manual intervention is needed to remedy any issues you might discover, you can temporarily pause management by clicking "Pause management of this resource".
