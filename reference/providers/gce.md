---
layout: single
title:  "Google Compute Engine"
sidebar:
  nav: reference
---

{% include toc %}

If you are not familiar with Google Compute Engine or any of the terms used below, please consult
Compute Engine's [reference documentation](https://cloud.google.com/compute).

## Resource Mapping

### Account
In [Google Compute Engine](https://cloud.google.com/compute) (GCE), an [Account](/setup/providers/#accounts)
maps to a credential able to authenticate against a given [Google Cloud Platform](https://cloud.google.com/) (GCP)
project - see the [setup guide](/setup/providers/gce).

### Load Balancer
A Spinnaker **load balancer** maps to a GCE [load balancer](https://cloud.google.com/compute/docs/load-balancing/). 

GCE supports many different types of load balancers, including: HTTPS(S), SSL Proxy, Network and Internal. Each of these
is supported by Spinnaker.

### Server Group
A Spinnaker **server group** maps to a GCE
[Managed Instance Group](https://cloud.google.com/compute/docs/instance-groups/creating-groups-of-managed-instances).

GCE allows for both zonal and
[regional](https://cloud.google.com/compute/docs/instance-groups/distributing-instances-with-regional-instance-groups)
Managed Instance Groups, and Spinnaker supports both types.

### Instance
A Spinnaker **instance** maps to a GCE [Virtual Machine Instance](https://cloud.google.com/compute/docs/instances/).

GCE supports [predefined machine types](https://cloud.google.com/compute/docs/machine-types#predefined_machine_types) as
well as [custom machine types](https://cloud.google.com/compute/docs/machine-types#custom_machine_types), and Spinnaker
has support for the full range.

### Security Group
A Spinnaker **security group** maps to a GCE [Firewall](https://cloud.google.com/compute/docs/vpc/firewalls).

Spinnaker has user-friendly support for associating a new server group with a set of security groups, and the correct
target tags will be set on the newly-provisioned server group.

## Operation Mapping

### Deploy

Deploys a GCE managed instance group.

A new GCE [instance template](https://cloud.google.com/compute/docs/instance-templates) is created for each new managed
instance group.

### Clone

Clones a GCE managed instance group.

Similar to a [deploy](#deploy) operation, except that most of the attributes are optional. Any elided attributes will be
inherited from the source managed instance group being cloned.

### Destroy 

Destroys a GCE managed instance group and its instance template.

If a managed instance group is serving traffic, it will first be [disabled](#disable).

### Resize

Resizes a GCE managed instance group.

If the managed instance group has an [autoscaler](https://cloud.google.com/compute/docs/autoscaler/) configured, resize
affects its min/max settings.

### Enable

Registers a GCE managed instance group with its associated load balancers and discovery service so that it can receive
traffic.

### Disable

Deregisters a GCE managed instance group from its associated load balancers and discovery service so that it no longer
receives traffic.

### Rollback

[Enables](#enable) one server group and [disables](#disable) another. The disable is only initiated once the
newly-enabled server group's instances are all determined to be healthy.

### Reboot Instance

Performs a [hard reset](https://cloud.google.com/compute/docs/instances/restarting-an-instance) on an instance.

### Terminate Instance

[Deletes](https://cloud.google.com/compute/docs/instances/stopping-or-deleting-an-instance#delete_an_instance) an
instance. In most cases, the managed instance group will provision a new instance to replace the terminated instance.

### Terminate Instance and Shrink Server Group

Atomically [deletes](https://cloud.google.com/sdk/gcloud/reference/compute/instance-groups/managed/delete-instances) an
instance and shrinks the target size of the managed instance group.

### Create Load Balancer

Upserts and wires together all of the necessary resources to support Network, HTTP(S), Internal or SSL load balancing.

Depending on the type of load balancing desired, an assortment of regional/gobal forwarding rules, target pools/proxies,
URL maps, backend services and health checks are required to be assembled. The create load balancer operation performs
all of this configuration implicitly.

### Edit Load Balancer

Modifies the attributes of an existing load balancer.

### Delete Load Balancer

Deletes a load balancer and all of its resources.

This operation is not permitted unless there are no instances associated with the load balancer.

### Create Security Group

Creates a firewall rule.

Target tags can be explicitly specified, or one can be automatically generated. Supports source filtering based on both
tags and CIDRs.

### Clone Security Group

Clones a firewall rule.

Supported only via the ui. The create security group wizard is pre-populated with the attributes of the security group

### Edit Inbound Rules

Modifies the source filters, target tags and ingress rules of an existing firewall rule.

### Delete Security Group

Deletes a firewall rule.
