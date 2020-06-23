---
layout: single
title:  "Delivery Configs"
sidebar:
  nav: guides
redirect_from: /reference/managed-delivery/delivery-configs/
---

{% include toc %}

_**Prerequisite:** read and complete the [getting started](/guides/user/managed-delivery/getting-started/) document!_

## What is a Delivery Config?

A **delivery config** allows you to group resources together in a single file (e.g. `spinnaker.yml`) and specify how these resources work together to promote an **artifact** between **environments**.

### Artifacts

An artifact represents the package or docker image that you want to promote in your delivery flow.
For example, if you develop the package `keeldemo` (which is built into a debian) and that is the only package that runs in your application, you'd have the following artifact section:

```yaml
artifacts:
- name: keeldemo
  type: deb
  reference: my-artifact   # optional human-readable reference to be used elsewhere in the config, defaults to artifact name
  vmOptions:               # only required for Debian artifacts, this information is used to determine how to bake a virtual machine image
    baseOs: bionic-classic # the base operating system for the virtual machine image
    regions:               # the regions to bake the image in (this should at least correspond to the regions you will deploy to)
    - us-west-2
    - us-east-1
    baseLabel: RELEASE     # the operating system label, optional and defaults to "RELEASE"
    storeType: EBS         # the storage type for the virtual machine image, optional and defaults to "EBS"
```

You can have multiple artifacts in your delivery config.
We will watch for new versions of every artifact you define.
In order to deploy a cluster that is running an artifact you'll need to use it within a resource (in an **Environment**).

_For detailed artifact information, please refer to the [Artifacts](/guides/user/managed-delivery/artifacts/) page._

### Environments

An environment represents all the infrastructure and instructions that are needed to run your package.
For example, we usually see environments like `dev`, `testing`, `staging`, `integration`, and `production`.
Each of these potentially have different resources, but are likely pretty homogeneous. 


A simple and supported workflow looks like this: 
 
1. Every build of your package should be deployed into your `testing` environment.
This environment might have a lower capacity, and a load balancer that only allows your team to access the running application.

1. Once your build has been deployed to `testing` and has come up as healthy, it should be promoted to your next environment (called `staging`).
Staging has a different capacity than `testing`. 

1. (Coming soon...)  Each build that has been healthy in staging is a candidate for `production`. 
Before deploying to `production` you must manually approve each version. 

#### Defining an Environment

An environment is made up of a list of declarative infrastructure resources (like the resource you created in the [getting started guide](/guides/user/managed-delivery/getting-started/)).
An environment is configured as follows:

```yaml
environments:
- name: testing
  resources: 
  - <full resource definition>
  - <another resource definition>
```  

That's all the config you need for a simple environment. 

#### Environment Notifications

You can add environment level notifications. 
They apply to all resources in the environment.
The config looks like:

```yaml
environments:
- name: testing
  resources: # omitted for brevity
  notifications:
  - type: slack
    address: "#managed-delivery"
    frequency: verbose
```

There are several `frequency` options:

* `verbose`: notification on task starting, completing, failing
* `normal`: notification on task completing or failing
* `quiet`: notification only for failure

There are two `type` options: 

* `email`: the address is the email address to send to
* `slack`: the address is the slack channel to send to (the spinnakerbot must be in the channel for you to receive notifications)

#### Environment Constraints

Constraints control how an artifact progresses through environments.

The config looks like:  

```yaml
environments:
- name: staging
  resources: # omitted for brevity
  notifications: # omitted for brevity
  constraints: 
  - type: depends-on
    environment: testing
```

This constraint definition says that an artifact must have been deployed successfully into the `testing` environment before it can be deployed into the `staging` environment.

A growing set of constraints are available, see [Environment Constraints](/guides/user/managed-delivery/environment-constraints)
for more information.

## Creating a delivery config

Let's pull it all together! Delivery configs must be stored in a file called `spinnaker.yml`. 
The rough structure is:

```yaml
name: sample-delivery-config
application: keeldemo
artifacts:
- name: keeldemo 
  type: deb
  reference: my-artifact
  vmOptions: # details omitted for brevity
environments:
- name: testing
  notifications: # omitted for brevity
  constraints: []
  resources: # details omitted for brevity
  - kind: ec2/cluster@v1
    # details
  - kind: ec2/classic-load-balancer@v1
    # details
- name: staging
  notifications: # omitted for brevity
  constraints: 
  - type: depends-on
    environment: testing
  resources: # details omitted for brevity
  - kind: ec2/cluster@v1
    # details
  - kind: ec2/classic-load-balancer@v1
    # details 
```

This shortened delivery config shows how to promote a debian artifact through two environments. 

Note that the first environment has no constraints.

## Example 

TODO eb: add an example 

