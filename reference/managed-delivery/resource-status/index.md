---
layout: single
title:  "Resource Status"
sidebar:
  nav: reference
---

{% include toc %}

💡 *If you're not sure what a Managed Resource is, check out our [overview of Managed Delivery](/reference/managed-delivery) first.*

## Overview
Managed Resources will always have a **status** which describes the current state of the resource from Spinnaker's perspective. A resource's status can help you quickly answer questions like:
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
Find the [ID of a resource](/reference/managed-delivery/getting-started/#find-your-resource-id) and call the `/managed/resources/<resourceId>/status` endpoint.

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

When a resource has a Created status, it means Spinnaker has just received the resource’s declarative configuration and hasn't taken any action yet.

If the actual state of the resource matches the declarative configuration, the resource will transition to the [Happy](/reference/managed-delivery/resource-status/#happy) status the next time Spinnaker checks it.

If Spinnaker detects a drift from the declarative configuration in the future, the resource will change status to [Diff](/reference/managed-delivery/resource-status/#diff). Once Spinnaker starts taking automatic action to correct the drift, the status will change to [Actuating](/reference/managed-delivery/resource-status/#actuating).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Diff
{%
  include
  figure
  image_path="./resource-status-diff.png"
%}

When a resource has a Diff status, it means Spinnaker detected a drift from the declarative configuration but hasn't taken any action yet.

Once Spinnaker starts taking automatic action to correct the drift, the status will change to [Actuating](/reference/managed-delivery/resource-status/#actuating).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Actuating
{%
  include
  figure
  image_path="./resource-status-actuating.png"
%}

When a resource has an Actuating status, it means Spinnaker detected a drift from the declarative configuration and an automatic action is in progress to resolve it. You can go to the Tasks view in your app to see the actions Spinnaker is taking on your behalf, and whether they succeeded or failed.

If automatic actions successfully resolve the drift, the status will change to [Happy](/reference/managed-delivery/resource-status/#happy). If automatic actions don't help to resolve the drift, the status will change to [Unhappy](/reference/managed-delivery/resource-status/#unhappy).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Happy
{%
  include
  figure
  image_path="./resource-status-happy.png"
%}

When a resource has a Happy status, all is well and the actual state of the resource matches its declarative configuration.

If Spinnaker detects a drift from the declarative configuration in the future, the resource status will change to [Diff](/reference/managed-delivery/resource-status/#diff). Once Spinnaker starts taking automatic action to correct the drift, the status will change to [Actuating](/reference/managed-delivery/resource-status/#actuating).

While Spinnaker is managing a resource, manual changes made via the UI or the API will be automatically reversed ("stomped") in favor of the declarative configuration.

### Unhappy
{%
  include
  figure
  image_path="./resource-status-unhappy.png"
%}

When a resource has an Unhappy status, it means Spinnaker detected a drift from the declarative configuration but hasn't been able to resolve it through automatic actions. This might mean that the actions Spinnaker has taken are failing, or something else is preventing the actions from having their desired effect.

While a resource is Unhappy, Spinnaker will continue trying to resolve the drift and may eventually succeed. If it does, the resource will transition to the [Happy](/reference/managed-delivery/resource-status/#happy) status.

You can go to the Tasks view in your app to see the actions Spinnaker is taking and troubleshoot. If you decide manual intervention is needed to remedy any issues you might discover, you can temporarily pause management on the Config view for your app.

### Paused
{%
  include
  figure
  image_path="./resource-status-paused.png"
%}

When a resource has a Paused status, it means Spinnaker is configured to continuously manage the resource but you've chosen to temporarily pause management. While management is paused Spinnaker won't check for drift from the declarative configuration, and it won't take any automatic actions. You can go to the Config view in your app to pause and resume management across the entire application.

When you resume management the status will change to [Resumed](/reference/managed-delivery/resource-status/#resumed).

### Resumed
{%
  include
  figure
  image_path="./resource-status-resumed.png"
%}

When a resource has a Resumed status, it means management was just resumed after being temporarily paused and Spinnaker hasn't checked for drift from the declarative configuration yet. You can go to the Config view in your app to pause and resume management across the entire application.

If a drift is detected, the status will change to [Diff](/reference/managed-delivery/resource-status/#diff). If no drift is detected, the status will change to [Happy](/reference/managed-delivery/resource-status/#unhappy).

### Error
{%
  include
  figure
  image_path="./resource-status-error.png"
%}

When a resource has an Error status, it means something went wrong while trying to check the resource for drift from its declarative configuration. Because something went wrong, Spinnaker can't take automatic actions and drift from the declarative configuration won't be resolved (until something changes). Some examples of problems that might lead to an error status:

  - A problem retrieving or processing information about the current state of the resource
  - A problem with the declarative configuration (invalid settings, etc.)
  - A bug or issue with Spinnaker itself

After an error, Spinnaker will continue trying to check the resource and may eventually succeed. If it does, the resource will transition to whatever status is applicable at that time.

If you see this status, it's probably best to investigate the current state of the resource manually and double check that nothing is broken. If you decide manual intervention is needed to remedy any issues you might discover, you can temporarily pause management on the Config view for your app.

### Unknown
{%
  include
  figure
  image_path="./resource-status-unknown.png"
%}

When a resource has an Unknown status, it means Spinnaker was unable to determine the current status for some reason. Because the status is unknown, it's tough to tell by the status alone whether something is *wrong*, or just unexpected.

After encountering this status, Spinnaker will continue trying to check the resource for its status and may eventually succeed. If it does, the resource will transition to whatever status is applicable at that time.

If you see this status, it's probably best to investigate the current state of the resource manually and double check that nothing is broken. If you decide manual intervention is needed to remedy any issues you might discover, you can temporarily pause management on the Config view for your app.
