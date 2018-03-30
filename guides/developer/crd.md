---
layout: single
title:  "Kubernetes CRD Extensions"
sidebar:
  nav: guides
redirect_from: /docs/crd-extensions
---

# Native Support For Kubernetes Custom Resource Definitions
Spinnaker's Kubernetes V2 provider natively supports Custom Resource Definitions (CRDs).

For example, inside a `clouddriver.yml` config, you can map your CRD to a `spinnakerKind` - `serverGroups`, `loadBalancers`, `instances`, etc.:

```
kubernetes:
  accounts:
    - name: my-kubernetes-account
      customResources:
        - kubernetesKind: myCRDKind
          spinnakerKind: serverGroups
```

Spinnaker will cache instances of your CRD, and the resource will be surfaced in the API and UI as your configured `spinnakerKind`.

# Spinnaker Extension Points for Custom Resource Definitions

At Google, we've built extension points for deep CRD integrations within Spinnaker.
These extension points live alongside the config-based support for CRDs described above.

This work has allowed us to support the following features within Spinnaker:

 - Custom models for representing CRDs as `spinnakerKinds`.
 - Deploying CRDs with custom Spinnaker artifact types.
 - Custom Kubernetes API versions.
 - Custom Spinnaker naming strategies.
 - Per-account, custom Spinnaker UIs that can run alongside the existing Kubernetes UIs.

This guide exists for developers that want to duplicate this functionality for their CRDs.
It also exists an explanation of certain code paths within Spinnaker which include hooks with no corresponding open-source implementations.

Developers that want to implement these features will have to build their own layered version
of [Clouddriver](https://github.com/spinnaker/clouddriver) -
see Adam Jorden's [blog post](https://blog.spinnaker.io/scaling-spinnaker-at-netflix-custom-features-and-packaging-e78536d38040) - and should be familiar with the Kubernetes V2 provider and writing code for Clouddriver.

## Custom Handlers

The central extension point is the `KubernetesHandler` class. A subclass of `KubernetesHandler` - e.g., `KubernetesReplicaSetHandler` - defines the
relationship between Spinnaker and your Kubernetes kind.

For example, if you wanted to build a Spinnaker integration for your CRD of kind `MyCRDKind`, you would start with
the following handler:

```
@Component
public class MyCRDHandler extends KubernetesHandler {

  public MyCRDHandler() {
    // Hook point for registering a custom `ArtifactReplacer`
    // for your CRD. During a deploy operation,
    // if an artifact of the type specified in the replacer is present,
    // the artifact will be inserted into the manifest using the
    // strategy described in the replacer.
  }

  @Override
  public KubernetesKind kind() {
    return "MyCRDKind";
  }

  @Override
  public boolean versioned() {
    // If the CRD resource should be versioned - i.e., assigned a sequence
    // v001, v002, etc.
    return false;
  }

  @Override
  public SpinnakerKind spinnakerKind() {
    // The Spinnaker kind that the resource will be represented as in Spinnaker's API and UI.
    return SpinnakerKind.SERVER_GROUPS;
  }

  @Override
  public Status status(KubernetesManifest manifest) {
    // Includes logic for determining whether your CRD manifest is stable.
    // A deploy manifest operation, for example, will block until this
    // method returns a stable status.
  }

  @Override
  public Class<? extends KubernetesV2CachingAgent> cachingAgentClass() {
    // Caching agent class for your CRD.
    // See, e.g., `KubernetesReplicaSetCachingAgent`.
    return MyCRDCachingAgent.class;
  }
}
```

## Custom Spinnaker Resource Models

Developers may want to change how their CRD is represented in Spinnaker's API. By default, a CRD of `spinnakerKind` `serverGroups` will
be represented with the model class `KubernetesServerGroup`.

Developers may want to override this representation, for example, if they want to define how their server group's `region` is resolved.

They can do so by having their `KubernetesJobHandler` implement `ServerGroupHandler` (or `ServerGroupManagerHandler` if their
resource is of `spinnakerKind` `serverGroupManagers`). They will be responsible for translating raw Spinnaker cache data into a
subclass of `KubernetesServerGroup`.

## Custom Kubernetes API Versions

Developers that want Spinnaker to support custom Kubernetes API versions should subclass `KubernetesApiVersion`.

For example,

```
public class MyApiVersion extends KubernetesApiVersion {
  public static MY_BETA_API_VERSION = new MyApiVersion("myApiVersion/v1beta");

  public MyApiVersion(String name) {
    // Base class maintains state.
    super(name);
  }
}
```

## Custom Spinnaker Naming Strategies

Developers that want to use a custom naming strategy for ther CRDs should implement a `NamingStrategy`. For example,

```
@Component
public class MyManifestNamer implements NamingStrategy<KubernetesManifest> {
  @Override
  public String getName() {
    return "myManifestNamingStrategy";
  }

  @Override
  public void applyMoniker(KubernetesManifest manifest, Moniker moniker) {
    // Strategy for applying a Spinnaker `Moniker` to a Kubernetes
    // manifest prior to deployment.
  }

  @Override
  public Moniker deriveMoniker(KubernetesManifest manifest) {
    // Strategy for deriving a Spinnaker `Moniker` from a Kubernetes
    // manifest.
  }
}
```

This naming strategy can be referenced in a Kubernetes account config. For example:

```
kubernetes:
  accounts:
    - name: my-kubernetes-account
      namingStrategy: myManifestNamingStrategy
```

Be careful - this naming strategy will be applied to all manifests manipulated by this account.

## Custom Spinnaker UIs

See the [reference repository](https://github.com/spinnaker/deck-customized) for developing Spinnaker UI customizations that
should not be open sourced.

Spinnaker's UI, Deck, has many points of integration to allow for per-cloud provider customization through the `CloudProviderRegistry`:

```
cloudProviderRegistryProvider.registerProvider('kubernetes', {
  name: 'Kubernetes',
  skin: 'v2',
  ... // References to components and templates that are rendered per cloud provider throughout Deck.
});
```

It's possible to override individual components and templates within the `CloudProviderRegistry` at build time
using Deck's `OverrideRegistry`.
However, these overrides are static and apply to every account using the UI implementation.

The UIs for Spinnaker's Kubernetes V1 & V2 providers are implemented as `skin`s. A `skin` is a named UI implementation for a given provider, and
is not strictly coupled to a backend implementation. By default, a Spinnaker Kubernetes account using the V1 provider implementation
will use the V1 skin; an account using the V2 implementation will use the V2 skin.

Developers can write custom skins for the Kubernetes provider by registering a new `skin` with the `CloudProviderRegistry`:

```
cloudProviderRegistryProvider.registerProvider('kubernetes', {
  name: 'Kubernetes',
  skin: 'myCustomizedUISkin',
  ... // References to components and templates. These do not all need to be custom components -
  ... // developers can mix in components from the V1 and V2 Kubernetes `skins`.
});
```

This skin can be referenced in a Kubernetes account config. For example:

```
kubernetes:
  accounts:
    - name: my-kubernetes-account
      skin: myCustomizedUISkin
```

A custom `skin` should be used in cases when some Kubernetes accounts should render the V1 or V2 `skin`, and others should use custom UI components.
If all Kubernetes accounts need the same customizations, then Deck's `OverrideRegistry` should be sufficient.

There is no strong relationship between CRDs and UI customizations - i.e., developers may want to have per-account UI customizations even
if they aren't using CRDs.
