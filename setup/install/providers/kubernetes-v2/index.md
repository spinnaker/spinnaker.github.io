---
layout: single
title:  "Kubernetes Provider V2 (Manifest Based)"
sidebar:
  nav: setup
---

{% include alpha version="1.6" %}

{% include toc %}

The Spinnaker Kubernetes V2 provider fully supports manifest-based deployments.
[Kubernetes provider V1](https://www.spinnaker.io/setup/install/providers/kubernetes/){:target="\_blank"}
is still supported.

## Accounts

For Kubernetes V2, a Spinnaker [Account](/concepts/providers/#accounts) maps to a
credential that can authenticate against your Kubernetes Cluster. Unlike with
the V1 provider, in V2 the Account does not require any Docker Registry
Accounts.

## Prerequisites

The Kubernetes provider has two requirements:

* A [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/){:target="\_blank"}

    The `kubeconfig` allows Spinnaker to authenticate against your cluster and
    to have read/write access to any resources you expect it to manage. You can
    request this from your Kubernetes cluster administrator.

* [`kubectl`](https://kubernetes.io/docs/user-guide/kubectl/){:target="\_blank"}

    Spinnaker relies on `kubectl` to manage all API access. It's installed
    along with Spinnaker.

    Spinnaker also relies on `kubectl` to access your Kubernetes cluster; only
    `kubectl` fully supports many aspects of the Kubernetes API, such as 3-way
    merges on `kubectl apply`, and API discovery. Though this creates a
    dependency on a binary, the good news is that any authentication method or
    API resource that `kubectl` supports is also supported by Spinnaker. This
    is an improvement over the original Kubernetes provider in Spinnaker.


<span class="begin-collapsible-section"></span>

### Optional: Create a Kubernetes Service Account

If you want, you can associate Spinnaker with a [Kubernetes Service
Account](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/),
even when managing multiple Kubernetes clusters. This can be useful if you need
to grant Spinnaker certain roles in the cluster later on, or you typically
depend on an authentication mechanism that doesn't work in all environments.

Given that you want to create a Service Account in context `$CONTEXT`, create
the following resources with `kubectl apply --context $CONTEXT ...`

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: spinnaker-service-account
  namespace: spinnaker

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: spinnaker-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: spinnaker-service-account
  namespace: spinnaker
```

> Note, this grants Spinnaker full access to the Kubernetes cluster using the
> `cluster-admin` role binding. This isn't necessary -- it's used as a simple
> example. For more fine-grained control, see the
> [RBAC](#optional-configure-kubernetes-roles-rbac) section.

Next, grab the token that this service account relies on:

```bash
TOKEN=$(kubectl get secret --context $CONTEXT \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context $CONTEXT \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
```

Place this token into your `kubeconfig` under a new user called
`${CONTEXT}-token-user`:

```bash
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN
```

Now configure your context `$CONTEXT` to use this new user:

```bash
kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
```

Now `$CONTEXT` will authenticate using the token we created above.

<span class="end-collapsible-section"></span>

<span class="begin-collapsible-section"></span>

### Optional: Configure Kubernetes roles (RBAC)

If your Kubernetes cluster supports
[RBAC](https://kubernetes.io/docs/admin/authorization/rbac/){:target="\_blank"}
and you want to restrict permissions granted to your Spinnaker account, you
will need to follow the below instructions.

The following YAML creates the correct `ClusterRole`, `ClusterRoleBinding`, and
`ServiceAccount`. If you limit Spinnaker to operating on an explicit list of
namespaces (using the `namespaces` option), you need to use `Role` &
`RoleBinding` instead of `ClusterRole` and `ClusterRoleBinding`, and apply the
`Role` and `RoleBinding` to each namespace Spinnaker manages. You can read
about the difference between `ClusterRole` and `Role`
[here](https://kubernetes.io/docs/admin/authorization/rbac/#rolebinding-and-clusterrolebinding){:target="\_blank"}.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: spinnaker-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "namespaces", "pods", "secrets", "services"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["list", "get"]
- apiGroups: ["apps"]
  resources: ["controllerrevisions", "deployments", "statefulsets"]
  verbs: ["*"]
- apiGroups: ["extensions", "app"]
  resources: ["daemonsets", "deployments", "ingresses", "networkpolicies", "replicasets"]
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

<span class="begin-collapsible-section"></span>

## Migrating from the V1 provider

> :warning: The V2 provider does __not__ use the [Docker Registry
> Provider](https://www.spinnaker.io/setup/install/providers/docker-registry/), and we
> encourage you to stop using the Docker Registry accounts in Spinnaker.  The
> V2 provider requires that you manage your private registry [configuration and
> authentication](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
> yourself.

There is no automatic pipeline migration from the V1 provider to V2, for a few
reasons:

* Unlike the V1 provider, the V2 provider encourages you to store your
  Kubernetes Manifests outside of Spinnaker in some versioned, backing storage,
  such as Git or GCS.

* The V2 provider encourages you to leverage the Kubernetes native deployment
  orchestration (e.g.
  [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/){:target="\_blank"})
  instead of the Spinnaker red/black, where possible.

* The initial operations available on Kubernetes manifests (e.g. scale, pause
  rollout, delete) in the V2 provider don't map nicely to the operations in the
  V1 provider unless you contort Spinnaker abstractions to match those of
  Kubernetes. To avoid building dense and brittle mappings between Spinnaker's
  logical resources and Kubernetes's infrastructure resources, we chose to
  adopt the Kubernetes resources and operations more natively.

However, you can easily migrate your _infrastructure_ into the V2 provider.
For any V1 account you have running, you can add a V2 account following the
steps [below](#adding-an-account). This will surface your infrastructure twice
(once per account) helping your pipeline & operation migration.

{% include figure image_path="./v1v2.png" caption="A V1 and V2 provider
surfacing the same infrastructure" %}

<span class="end-collapsible-section"></span>

## Adding an account

First, make sure that the provider is enabled:

```bash
hal config provider kubernetes enable
```

Then add the account:

```bash
hal config provider kubernetes account add my-k8s-v2-account \
    --provider-version v2 \
    --context $(kubectl config current-context)
```

You'll also need to run

```bash
hal config features edit --artifacts true
```

## Advanced account settings

If you're looking for more configurability, please see the other options listed
in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-kubernetes-account-add).
