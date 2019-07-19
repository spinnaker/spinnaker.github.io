---
layout: single
title:  "Component Sizing"
sidebar:
  nav: reference
---

{% include toc %}


Custom sizing can be specified for each Spinnaker component within the Halyard configuration. You can either add these sizes to the Halyard config manually, or use any of the [Halyard component sizing commands](https://www.spinnaker.io/reference/halyard/commands/#hal-config-deploy-component-sizing). This feature is currently only supported for distributed deployments using Kubernetes (`hal config deploy edit --type distributed --account-name my-k8s-cluster`).

## Kubernetes
The following Kubernetes settings can be tweaked within custom sizing. 

### CPU & Memory requests/limits

Container requests and limits for cpu and memory can be specified in the `deploymentEnvironment.customSizing` section of the halconfig file. 

There are two ways to specify requests and limits

* _(Recommended)_ By supplying the container name, e.g. `echo:`, followed by the container requests and limits.

  This sets resource configuration for the echo container in `spin-echo` service's pod only, not any sidecars
  (e.g. the monitoring daemon).
   
* By supplying the service name, e.g. `spin-clouddriver:`, followed by the container requests and limits.

  This sets the resource configuration for the clouddriver container as well as any sidecar containers in the
  `spin-clouddriver` service.

Here is an example of this configuration:

```yaml
deploymentEnvironment:
  customSizing:
    # This applies sizings to only the echo container and not to any sidecar 
    # containers running with echo.
    echo:
      limits:
        cpu: 250m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 128Mi
    # This applies sizings to the clouddriver container as well as any sidecar 
    # containers running with clouddriver.
    spin-clouddriver:
      limits:
        cpu: 1
        memory: 1Gi
      requests:
        cpu: 250m
        memory: 512Mi
```

Limits and requests follow the Kubernetes conventions [documented here](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/).

#### Updating JAVA_OPTS

All JVM-based services have the following JAVA_OPTS set:

```
JAVA_OPTS=-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=2
```

This sets the JVM's heap size to half the memory allocated per container. This can be overriden by specifying your own `JAVA_OPTS` 
using the `env` key in [service-settings](/reference/halyard/custom/#tweakable-service-settings).

As a starting point, the `-Xms` can be set to 80%-90% of the requests memory allotment and `-Xmx` can be set to 80-90% of the limits memory allotment. For the clouddriver example above, the `env` key is as follows:

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
