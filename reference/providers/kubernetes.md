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

### Server Group

A Spinnaker **Server Group** maps to a Kubernetes [Replica
Set](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).
The Spinnaker API resource is defined
[here](https://github.com/spinnaker/clouddriver/blob/master/clouddriver-kubernetes/src/main/groovy/com/netflix/spinnaker/clouddriver/kubernetes/deploy/description/servergroup/DeployKubernetesAtomicOperationDescription.groovy).

When Spinnaker creates a Server Group named `${SERVER-GROUP}` it sets the
following Pod labels:

```yaml
template:
  metadata:
    labels:
      ${SERVER-GROUP}: true
```

Furthermore, using the [Docker Registry](/setup/providers/docker-registry/)
accounts associated with the Kubernetes Account being deployed to, a list of
[Image Pull
Secretes](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)
already populated by Spinnaker are attached to the created Pod definition. This
ensures that images from private registries can always be deployed. Image Pull
Secrets named based on their Docker Registry account name in Spinnaker, so
deploy to a Kuberentes account configured with `--docker-registries
${DOCKER-REGISTRY}`, the following will appear in the Pod template:

```yaml
template:
  spec:
    imagePullSecrets:
      - name: ${DOCKER-REGISTRY}
```

### Load Balancer

A Spinnaker **Load Balancer** maps to a Kubernetes
[Service](https://kubernetes.io/docs/concepts/services-networking/service/).
You can configure which type of Service to deploy by picking a [Service
Type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types).

When Spinnaker creates a service with name `${LOAD-BALANCER}`, it sets the 
following selector:

```yaml

spec:
 selector:
   # added by Spinnaker
   load-balancer-${LOAD-BALANCER}: true 

```

This is done so that when you create a **Server Group** in Spinnaker, and
attach it to a **Load Balancer**, Spinnaker can easily enable and disable
traffic to individual pods by editing their labels like so:

#### Enabled pod (receiving traffic) 

```yaml

metadata:
  labels:
    load-balancer-${LOAD-BALANCER}: true
    ... # other labels

```

#### Disabled pod (not receiving traffic) 

```yaml

metadata:
  labels:
    load-balancer-${LOAD-BALANCER}: false
    ... # other labels

```

#### Enabled pod (receiving traffic from multiple sources) 

```yaml

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

