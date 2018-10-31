---
layout: single
title:  "Oracle Cloud"
sidebar:
  nav: reference
---

{% include toc %}

For more information about Oracle Cloud or any of the terms used below, please consult
[Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/iaas/Content/home.htm).

## Resource mapping

### Account
The Oracle Cloud provider in Spinnaker maps a Spinnaker [__Account__](/concepts/providers/#accounts)
to an [Oracle Cloud Infrastructure user](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/addingusers.htm) in 
[Oracle Cloud Infrastructure](https://cloud.oracle.com/) (OCI). 
Spinnaker authenticates itself with Oracle Cloud using OCI user credentials - 
see the [setup guide](/setup/providers/oracle). 

### Load Balancer
A Spinnaker **load balancer** maps to an [OCI Load Balancer](https://docs.cloud.oracle.com/iaas/Content/Balance/Concepts/balanceoverview.htm).

The OCI Load Balancing service offers a load balancer with your choice of a public or private IP
address, and provisioned bandwidth. The essential components for load balancing include:
* A load balancer with pre-provisioned bandwidth.
* A backend set with a health check policy. See [Managing Backend Sets](https://docs.cloud.oracle.com/iaas/Content/Balance/Tasks/managingbackendsets.htm).
* One or more listeners . See [Managing Load Balancer Listeners](https://docs.cloud.oracle.com/iaas/Content/Balance/Tasks/managinglisteners.htm).
* Optionally, you can associate your listeners with SSL server certificates to manage how your system handles SSL traffic. See [Managing SSL Certificates](https://docs.cloud.oracle.com/iaas/Content/Balance/Tasks/managingcertificates.htm).

### Server Group
A Spinnaker **server group** maps to a group of [OCI Virtual Machine Instances](https://docs.cloud.oracle.com/iaas/Content/Compute/Concepts/computeoverview.htm).

### Instance
A Spinnaker **instance** maps to an [OCI Virtual Machine Instance](https://docs.cloud.oracle.com/iaas/Content/Compute/Concepts/computeoverview.htm).

When you launch an instance, you choose the most appropriate shape which is a template describing 
the number of CPUs, amount of memory, and other resources allocated to a newly created instance. 
See [Compute Shapes](https://docs.cloud.oracle.com/iaas/Content/Compute/References/computeshapes.htm) 
for a list of available VM shapes.

### Firewall
In OCI, a [security list](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/securitylists.htm) 
provides a virtual firewall for an instance, with ingress and egress rules that specify the types 
of traffic allowed in and out. Each security list is enforced at the instance level.

The Oracle Cloud provider in Spinnaker currently does not support the ability to create firewalls 
for Oracle Cloud from Spinnaker. You can use the Oracle Cloud console to create and manage Security 
Lists to provide a virtual firewall for an instance.

## Operation mapping

### Deploy

Deploys a group of VM instances in OCI.

The Oracle Cloud provider in Spinnaker creates an Oracle Object Storage bucket named `_spinnaker_server_group_data`
in the user’s tenancy to keep track of all the server groups created.

If a deployed server group is configured with load balancer, all VM instances of the server group 
are added to the backend set of corresponding listener in the load balancer.

### Destroy

Destroys a server group and terminates all its VM instances. This also removes the server group 
information stored in `_spinnaker_server_group_data` bucket. If the server group is configured with 
a load balancer, all the VM instances of the server group are removed from the backend set.

### Resize

Resizes a server group. If the server group is configured with load balancer, Oracle Cloud provider 
adds launched VM instances to the backend set, and removes terminated VM instances from the backend
set.

### Create Load Balancer

Creates a new Load Balancer in OCI.

Before you can implement a working OCI Load Balancer, you need:
* A VCN with at least two public subnets for a public load balancer. Each subnet must reside in a 
separate availability domain. For more information on subnets, 
See [VCNs and Subnets](https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingVCNs.htm) 
and [Public vs. Private Subnets](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm#Public).
* A VCN with at least one subnet for a private load balancer.

### Delete Load Balancer

Deletes a load balancer and all of its resources.
