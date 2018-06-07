---
layout: single
title:  "Kubernetes (legacy provider)"
sidebar:
  nav: setup
redirect_from: /setup/providers/kubernetes/
---

{% include toc %}

For the Kubernetes provider, a Spinnaker [Account](/concepts/providers/#accounts)
maps to a credential that can authenticate against your Kubernetes Cluster. It
also includes a set of one or more [Docker
Registry](/setup/providers/docker-registry) accounts that are used as a source
of images.

When setting your your Kubernetes provider account, you will [use halyard
to add the account](#), then provide any Docker registries that you'll use.

## Prerequisites

<span class="begin-collapsible-section"></span>

### You need a Kubernetes cluster and its credentials

You need a running Kubernetes cluster, with corresponding credentials in a
[kubeconfig file](https://kubernetes.io/docs/concepts/cluster-administration/authenticate-across-clusters-kubeconfig/){:target="\_blank"}.

If you have these, you can verify the credentials work by running this command
on a machine that has the credentials and has
[`kubectl`](https://kubernetes.io/docs/user-guide/kubectl-overview/){:target="\_blank"}
installed:

```bash
kubectl get namespaces
```

> Note: Halyard on Docker comes with `kubectl` already installed. Halyard on
> Ubuntu does not.

If you don't have a Kubernetes cluster, you can try one of these hosted
solutions:

* [Google Kubernetes Engine](https://cloud.google.com/container-engine/){:target="\_blank"}

  For authentication to work, you need to [use legacy cluster certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/iam-integration#authentication_modes){:target="\_blank"}.
  This is because of limitations in the client library that the Kubernetes legacy
  provider depends on.

* [Azure Container
  Service](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-walkthrough){:target="\_blank"}

* [EKS](https://aws.amazon.com/eks/){:target="\_blank"}

Or pick a different [solution that works for
you](https://kubernetes.io/docs/setup/pick-right-solution/){:target="\_blank"}.

Consult the documentation for your environment to find out how to get the
`kubeconfig` that you must provide to Halyard.

<span class="end-collapsible-section"></span>

<span class="begin-collapsible-section"></span>

### You need a Docker registry

To use the Kubernetes (legacy) provider, you need a Docker registry as a source
of images. To enable this, you set up a Docker registry as another provider, [as
described here](/setup/providers/docker-registry), and add any registries that
contain images you want to deploy.

You can verify your Docker registry accounts using this command:

```bash
hal config provider docker-registry account list
```

When you [add your Kubernetes provider account](#adding-an-account), you include
your registry (or registries) in the command.

<span class="end-collapsible-section"></span>

<span class="begin-collapsible-section"></span>

### Optional: configure Kubernetes roles (RBAC)

If you use Kubernetes RBAC for access control, you may want to create a minimal
Role and Service Account for Spinnaker. This ensures that Spinnaker has only the
permissions it needs to operate within your cluster.

The following YAML creates the correct `ClusterRole`, `ClusterRoleBinding`,
and `ServiceAccount`. If you're limiting Spinnaker to an explicit list of
namespaces (using the `namespaces` option), you need to use `Role` &
`RoleBinding` instead of `ClusterRole` and `ClusterRoleBinding`, and create one
in each namespace Spinnaker will manage. You can read about the difference
between `ClusterRole` and `Role` [here](https://kubernetes.io/docs/admin/authorization/rbac/#rolebinding-and-clusterrolebinding){:target="\_blank"}.


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
  resources: ["pods", "pods/portforward", "services", "services/proxy", "secrets"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["list", "get"]
- apiGroups: ["apps"]
  resources: ["controllerrevisions", "statefulsets"]
  verbs: ["list"]
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
 kind: ClusterRole
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

<span class="end-collapsible-section"></span>

## Add a Kubernetes account

First, make sure that the provider is enabled:

```bash
hal config provider kubernetes enable
```

Now, assuming you have a Docker Registry account named `my-docker-registry`,
run the following `hal` command to add that to your list of Kubernetes accounts:

```bash
hal config provider kubernetes account add my-k8s-account \
    --docker-registries my-docker-registry
```

## Advanced account settings

If you are looking for more configurability, see the available options in the
[Halyard Reference](/reference/halyard/commands#hal-config-provider-kubernetes-account-add).

## Next steps

Optionally, you can [set up another cloud provider](/setup/install/providers/),
but otherwise you're ready to [choose the environment](/setup/install/environment/)
in which to install Spinnaker.
