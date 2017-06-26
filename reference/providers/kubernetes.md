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

### Instance

A Spinnaker **Instance** maps to a Kubernetes
[Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/). What
differentiates this from other Cloud Providers is the ability for Pods to run
multiple containers at once, whereas typical IAAS providers in Spinanker run
exactly one image per Instance. This means that extra care must be taken when
updating Pods with more than container to ensure that the correct container is
replaced.

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
Secrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)
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

### Cluster

A Spinnaker **Cluster** can optionally map to a Kubernetes
[Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
There are two things to take note of here:

1. Typically, in Spinnaker, Clusters are a logical grouping, not backed by a
   Cloud Provider's infrastructure. However, since both Kubernetes and
   Spinnaker use Deployments and Clusters respectively to represent versioned,
   replicated sets of Instances that are updated by some orchestration
   mechanism, this is an apt mapping.
2. This mapping is optional because Spinnaker's orchestration capabilities do
   not require Deployment objects to exist to handle udpates. In fact, one
   __should not__ attempt to let Spinnaker's orchestration (Red/Black,
   Highlander) manage Server Groups handled by Kubernetes' orchestration
   (Rolling Update), since do not, and are not intended to work together.

The labeling scheme is a little more complex when Deployment objects are
involved, because Kubernetes deployments find Pods to manage using
label-selectors in the same way that Replica Sets do; however, if the
Deployments and Replica Sets share the same set of label-selectors, every
Replica Set created/managed by that Deployment will compete to own the same set
of Pods, but with different Pod Spec definitions. Therefore, the labeling
scheme for a Deployment in Cluster `${CLUSTER-NAME}` with sequence number
(`vNNN`) `${SEQUENCE-NUMBER}`, and active server group
`SERVER-GROUP-NAME=${CLUSTER-NAME}-v${SEQUENCE-NUMBER}` looks like this:

```yaml
# irrelevant details ommitted
kind: Deployment
metadata:
  name: ${CLUSTER-NAME}
spec:
  selector:
    matchLabels:
      ${CLUSTER-NAME}: true
  template:
    metadata:
      labels:
        ${CLUSTER-NAME}: true
        version: ${SEQUENCE-NUMBER} # used to distinguish the replica set
        ${SERVER-GROUP-NAME}: true  # used to distinguish the replica set
```

Meanwhile, to circumvent Kubernetes' naming of Replica Sets and impose
Spinnaker's naming convention, Spinnaker will also create a Replica Set before
one is created by the Deployment, with the following labeling scheme:

```yaml
kind: Deployment
metadata:
  name: ${SERVER-GROUP-NAME}
spec:
  selector:
    matchLabels:
      ${SERVER-GROUP-NAME}: true
      version: ${SEQUENCE-NUMBER}
  template:
    metadata:
      labels:
        ${CLUSTER-NAME}: true
        version: ${SEQUENCE-NUMBER}
        ${SERVER-GROUP-NAME}: true
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

## Operation Mapping

This enumerates the various "Atomic Operations" and how they modify Kubernetes
resources.

### Deploy

When deploying a Replica Set, Spinnaker sets all labels as described in the
[Server Group](#server-group) and [Load Balancer](#load-balancer) sections
above, adds the necessary `ImagePullSecrets` for your desired docker
containers, and then creates the Replica Set with all properties you've
specified. 

When deploying a Replica Set with a Deployment, and the Deployment doesn't
exist, Spinnaker first creates the Replica Set with `replicas: 0`, and then
creates the Deployment which will resize the Replica Set. When the Deployment
does exist, does the same, but edits the Deployment in place rather than
creating it.

### Clone

This operates the same as __Deploy__; however, the properties the server group
is deployed with are the result of merging those of the server group being
cloned, and those specified in the operation, prefering those specified in the
operation.

### Destroy

This will delete whichever controler you are operating on. If you are deleting
the must current Replica Set under a Deployment, Spinnaker will attempt to
delete the Deployment as well.

### Resize

When no autoscaler is attached, this updates the `replicas` count on the
controller you are modifying. When an autoscaler is attached, it edits the
min/max bounds specified on the attached autoscaler. Spinnaker will
automatically detect if an Autoscaler exists for a resource, as long as it
contains a resource reference pointing to your controller, and the
Controller and Autoscaler's names match.

### Enable

First this edits the target controller's Pod Spec to set each label matching
`load-balancer-*: ` to `true`. Then each pod owned by the controller will have
the same transformation applied in parallel.

### Disable

The same as __Enable__, but substituting `true` for `false`.

### Rollback

This is a combination of Enable & Disable, where the server group being rolled
back to is first enabled, and once all health checks pass, the server group
being rolled back from is disabled.

### Terminate Instance

This invokes the delete operation on the given Pod. If this pod is managed by a
controller, (e.g. a Replica Set), it will be recreated by that controller, but
likely with a different name.

### Create Load Balancer

Creates a Kubernetes service with labels matching those shown
[above](#load-balancer).

### Edit Load Balancer

Edits the chosen service by recreating it, setting any new properties
supplied in the operation.

### Delete Load Balancer

Deletes the service - this will not edit any pods associated with the service.
