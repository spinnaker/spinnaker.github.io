---
layout: single
title:  "OpenStack"
sidebar:
  nav: setup
---

{% include toc %}

## Prerequisites

The Spinnaker Openstack driver is developed and tested against the Openstack Mitaka release.
Due to the limitless ways to configure Openstack and its services,
here is a list of API versions that are required to be enabled:

* Keystone (Identity) v3
* Compute v2
* LBaaS v2
* Networking v2
* Orchestration (Heat)
* Ceilometer
* Telemetry Alarming (Aodh)
* Glance v1

You will need an account admin permissions for Spinnaker to use. You can download the [openrc](https://docs.openstack.org/user-guide/common/cli-set-environment-variables-using-openstack-rc.html) from your Horizon UI. To test your setup, use the the [OpenStack command line client](https://docs.openstack.org/developer/python-openstackclient/).

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider openstack enable
```

The OpenStack account information is in your openrc.sh. Run the following `hal` command to add an account named `my-openstack-account` to your list of OpenStack accounts, filling your specific information as needed:


```bash
hal config provider openstack account add my-openstack-account \
    --auth-url http://authurl:5000/v3  --username service-account \
    --domain-name default --regions RegionOne --project-name the-project \
    --password service-password
```

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-openstack-account-add).

If managing load balancers in your Openstack environment through Spinnaker is failing due to timeouts, you may need to increase the timeout and polling interval.
This is more likely to occur in a resource constrained Openstack environment such as Devstack or another smaller test environment.
Openstack requires that the load balancer be in an ACTIVE state for it to create associated relationships (i.e. listeners, pools, monitors).
Each modification will cause the load balancer to go into a PENDING state and back to ACTIVE once the change has been made.
Spinnaker needs to poll Openstack, blocking further load balancer operations until the status returns to ACTIVE.

### Common Userdata

The OpenStack driver supports the ability to inject common userdata into every launched instance.
This is handled via a template file that is located on the Clouddriver server.
This template file is token replaced to provide some specifics about the deployment.

The location of the template file is controlled by the `--user-data-file` flag.

| **Token** | **Description** |
| --- | --- |
| `%%account%%`	| the name of the account |
| `%%accounttype%%`	| the accountType of the account |
| `%%env%%`	| the environment of the account |
| `%%region%%` | the deployment region |
| `%%group%%`	| the name of the server group |
| `%%autogrp%%`	| the name of the server group |
| `%%cluster%%`	| the name of the cluster |
| `%%stack%%`	| the stack component of the cluster name |
| `%%detail%%`	| the detail component of the cluster name |
| `%%launchconfig%%` | the name of the launch configuration |


Typical usage would be replacing these values into a list of environment variables, and using those variables to customize behavior based on the account/env/stack/etc.

Example template file:

```bash
#!/bin/bash
CLOUD_ACCOUNT="%%account%%"
CLOUD_ACCOUNT_TYPE="%%accounttype%%"
CLOUD_ENVIRONMENT="%%env%%"
CLOUD_SERVER_GROUP="%%group%%"
CLOUD_CLUSTER="%%cluster%%"
CLOUD_STACK="%%stack%%"
CLOUD_DETAIL="%%detail%%"
CLOUD_REGION="%%region%%"
```
If the server group udf-example-cluster-v001 was deployed using this template in the account main, accountType streaming, environment prod, in the east region, the resulting user data would look like:

```bash
#!/bin/bash
CLOUD_ACCOUNT="main"
CLOUD_ACCOUNT_TYPE="streaming"
CLOUD_ENVIRONMENT="prod"
CLOUD_SERVER_GROUP="udf-example-cluster-v001"
CLOUD_CLUSTER="udf-example-cluster"
CLOUD_STACK="example"
CLOUD_DETAIL="cluster"
CLOUD_REGION="east"
```
