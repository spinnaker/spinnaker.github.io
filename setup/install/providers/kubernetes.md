---
layout: single
title:  "Kubernetes"
sidebar:
  nav: setup
redirect_from: /setup/providers/kubernetes.html
---

{% include toc %}

In Kubernetes, an [Account](/concepts/providers/#accounts) maps to a
credential able to authenticate against your desired Kubernetes Cluster, as 
well as a set of [Docker Registry](/setup/providers/docker-registry) accounts 
to be used as a source of images.

## Prerequisites

Both the Kubernetes credentials and Docker Registry accounts must exist before
Halyard will allow you to add a Kubernetes account. The sections below will
help you create these resources if you do not already have them.

### Kubernetes Cluster

You need to have a running Kubernetes cluster with corresponding credentials in
a [kubeconfig file](https://kubernetes.io/docs/concepts/cluster-administration/authenticate-across-clusters-kubeconfig/).
If you do have a running cluster and credentials, you can verify that your
credentials work using
[`kubectl`](https://kubernetes.io/docs/user-guide/kubectl-overview/) to run the
following command:

```bash
kubectl get namespaces
```

If you do not have a Kubernetes cluster, you could try one of the following
hosted solutions:

* [Google Kubernetes Engine](https://cloud.google.com/container-engine/)
* [Azure Container
  Service](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-walkthrough)

Or, you can read more on the Kubernetes setup page to pick a [solution that
works for you](https://kubernetes.io/docs/setup/pick-right-solution/).

### Kubernetes Role (RBAC)

If you are using Kubernetes RBAC for access control, you may want to create a minimal for Role and Service Account for Spinnaker.
This will ensure that Spinnaker has only the permissions it needs to operate within your cluster.

The following YAML can be used to create the correct `ClusterRole`, `ClusterRoleBinding`, and `ServiceAccount`. If you are limiting
Spinnaker to an explicit list of namespaces (using the `namespaces` option), you will need to use `Role` & `RoleBinding` instead of
`ClusterRole` and `ClusterRoleBinding` and create one in each namespace Spinnaker will manage. You can read about the difference
between `ClusterRole` and `Role` [here](https://kubernetes.io/docs/admin/authorization/rbac/#rolebinding-and-clusterrolebinding).


```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: spinnaker-role
rules:
- apiGroups: [""]
  resources: ["namespaces", "configmaps", "events", "replicationcontrollers", "serviceaccounts", "pods/logs"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "services", "secrets"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["list", "get"]
- apiGroups: [“apps”]
  resources: [“controllerrevisions”, "statefulsets"]
  verbs: [“list”]
- apiGroups: ["extensions", "app"]
  resources: ["deployments", "replicasets", "ingresses", "daemonsets"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
 name: spinnaker-role-binding
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: Role
 name: spinnaker-role
subjects:
- namespace: default
  kind: ServiceAccount
  name: spinnaker-service-account
---
apiVersion: v1
kind: ServiceAccount
metadata:
 name: spinnaker-service-account
 namespace: default
```

### Docker Registries

Follow the steps under the [Docker Registry](/setup/providers/docker-registry)
provider to add any registries containing images you want to deploy. If
you have already done so, you can verify that these accounts exist by running:

```bash
hal config provider docker-registry account list
```

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider kubernetes enable
```

Now, assuming you have a Docker Registry account named `my-docker-registry`,
run the following `hal` command to add an account named `my-k8s-account` to
your list of Kubernetes accounts:

```bash
hal config provider kubernetes account add my-k8s-account \
    --docker-registries my-docker-registry
```

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-kubernetes-account-add).

## Next Steps

Optionally, you can [set up another cloud provider](/setup/install/providers/), but otherwise you're ready to [Deploy Spinnaker](/setup/install/deploy/).