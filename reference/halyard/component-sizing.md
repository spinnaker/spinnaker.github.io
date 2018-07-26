---
layout: single
title:  "Component Sizing"
sidebar:
  nav: reference
---

{% include toc %}


Within the Halyard Configuration custom sizing can be specified for each Spinnaker component. Custom sizing must be manually added to the Halyard Configuration, there are no CLI commands or flags to enable these settings. This feature is currently only supported for distributed deployments using Kubernetes (`hal config deploy edit --type distributed --account-name my-k8s-cluster`).

## Kubernetes
The following Kubernetes settings can be tweaked within custom sizing. 

### CPU & Memory requests/limits

Container requests and limits for cpu and memory can be specified in the customSizing section of the Halyard Configuration. Note that if you specify the service name, these sizings will also be applied to any sidecars running alongside the primary container. To apply sizing to only a specfic container and not the sidecars, specify the container name instead of the service name. Please see the example for details.

```
deploymentEnvironment:
  customSizing:
    # This applies sizings to the cloudriver container as well as any sidecar 
    # containers running with clouddriver.
    spin-clouddriver:
      limits:
        cpu: 1
        memory: 1Gi
      requests:
        cpu: 250m
        memory: 512Mi
    # This applies sizings to only the echo container and not to any sidecar 
    # containers running with echo.
    echo:
      limits:
        cpu: 250m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 128Mi
```

Limits and requests follow the Kubernetes conventions [documented here](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/).

#### Updating JAVA_OPTS

The shaping of the pods via request and limits will not cap the java processes for the Spinnaker microservice. This can be achieved by using the `env` key in [service-settings](/reference/halyard/custom/#tweakable-service-settings).

In general, the `-Xms` will follow 80%-90% of the requests memory allotment and `-Xmx` will follow 80-90% of the limits memory allotment. For the clouddriver example above, the `env` key is as follows:

```
env:
   JAVA_OPTS: "-Xms410m -Xmx819m
```

#### Recommendations

It is not recommended that limits and requests be applied to the bootstrapping pods. These pods can be scaled down to 0 once `hal deploy apply` has been completed. They will be relaunched the next time a `hal deploy apply` is executed.

Optimal sizings for your components will depend upon your environment, but in general clouddriver and orca will need to be larger than the rest of the components, additionally echo may also need to be larger if using event hooks.

### Replicas

The number of desired replicas for a component can be specified within customSizing like so:
```
customSizing:
  spin-[component name]:
    replicas: 2
```
If the number of replicas isn't specified for a component halyard will deploy said component with the same number of replicas it had during the previous deployment. On the initial deployment of spinnaker all pods will default to 1 replica if nothing is specified within customSizing.

__Important:__ To avoid duplicate triggering, echo and igor must each be deployed with exactly one pod.
