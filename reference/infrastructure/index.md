---
layout: single
title:  "Deployment Infrastructure"
sidebar:
  nav: reference
---

{% include toc %}


* [Application](#application)
* [Cluster](#cluster)
* [Server group](#server-group)
* [Load balancer](#load-balancer)
* [Firewall](firewall)

## Application
An application in Spinnaker is a collection of clusters, which in turn are
collections of server groups. The application also includes firewalls and load
balancers.


Configuration for an application includes the following fields:

| Field | Required | Description |
| --- | --- | --- |
| Name  | Yes | A unique name to identify this application. |
| Owner Email | Yes | The email address of the owner of this application, within your installation of Spinnaker. |
| Repo type | No | The platform hosting the code repository for this application. Stash, Bitbucket, or GitHub. |
| Description | No | Use this text field to describe the application, if necessary. |
| Consider only cloud provider health | N/A | If enabled, instance status as reported by the cloud provider is considered sufficient to determine task completion. When disabled, tasks need health status reported by some other health provider (load balancer, discovery service).|
| Show health override option | N/A | If enabled, users can toggle previous option per task. |
| Instance port | No | This field is used to generate links from Spinnaker instance details to a running instance. The instance port can be used or overridden for specific links configured for your application (via the Config screen). |
| Enable restarting running pipelines | N/A | If enabled, users can restart pipeline stages while a pipeline is still running. This behavior is not recommended. |

## Cluster



## Server group


## Load balancer



## Firewall
