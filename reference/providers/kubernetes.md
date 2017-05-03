---
layout: single
title:  "Kubernetes"
sidebar:
  nav: reference
---

{% include toc %}

If you are not familiar with Kubernetes or some of the Kubernetes terminology
used below, please read the [reference
documentation](https://kubernetes.io/docs/home).

## Resource Mapping

### Account

In Kubernetes, an [Account](/setup/providers/#accounts) maps to a
credential able to authenticate against your desired Kubernetes Cluster, as 
well as a set of [Docker Registry](/setup/providers/docker-registry) accounts 
to be used as a source of images.

### Load Balancer

A Spinnaker **Load Balancer** maps to a Kubernetes
[Service](https://kubernetes.io/docs/concepts/services-networking/service/).
You can configure which type of Service to deploy by picking a [Service
Type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types).

When Spinnaker creates a service with name `${LOAD-BALANCER}`, it sets the 
following selector:

```yml

spec:
 selector:
   # added by Spinnaker
   load-balancer-${LOAD-BALANCER}: true 

```

This is done so that when you create a **Server Group** in Spinnaker, and
attach it to a **Load Balancer**, Spinnaker can easily enable and disable
traffic to individual pods by editing their labels like so:

#### Enabled pod (receiving traffic) 

```yml

metadata:
  labels:
    load-balancer-${LOAD-BALANCER}: true
    ... # other labels

```

#### Disabled pod (not receiving traffic) 

```yml

metadata:
  labels:
    load-balancer-${LOAD-BALANCER}: false
    ... # other labels

```

#### Enabled pod (receiving traffic from multiple sources) 

```yml

metadata:
  labels:
    load-balancer-${LOAD-BALANCER-1}: true
    load-balancer-${LOAD-BALANCER-2}: true
    load-balancer-${LOAD-BALANCER-3}: true
    ... # other labels

```

As seen above, this is how Spinnaker supports an __M__:__N__ relationship
between pods and services.

> __NOTE__: This hard-naming dependency is liable to loosen and change in
> future releases of Spinnaker. We realize this makes it more difficult to
> import existing deployed applications into Spinnaker, and would prefer to
> switch to a model that allows users to make any label-based association 
> between pods and services.

