---
layout: single
title:  "Component Sizing"
sidebar:
  nav: reference
---

{% include toc %}


Within the halconfig custom sizing can be specified for each Spinnaker component. Custom sizing must be manually added to the halconfig, there are no CLI commands or flags to enable these settings. This feature is currently only supported for distributed deployments using Kubernetes (`hal config deploy edit --type distributed --account-name my-k8s-cluster`).

## Kubernetes

Container requests and limits for cpu and memory can be specified in the customSizing section of the halconfig. Note that these sizings will also be applied to any sidecars running along side the container as well. Please see the example for details.

### Example
```
deploymentEnvironment:
  customSizing:
    spin-clouddriver:
      limits:
        cpu: 1
        memory: 1Gi
      requests:
        cpu: 250m
        memory: 512Mi
    spin-echo:
      limits:
        cpu: 250m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 128Mi
```

Limits and requests follow the Kubernetes conventions [documented here](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/).

### Updating JAVA_OPTS

The shaping of the pods via request and limits will not cap the java processes for the Spinnaker microservice. This can be achieved by using the `env` key in [service-settings](references/halyard/custom/#tweakable-service-settings).

In general, the `-Xms` will follow 80%-90% of the requests memory allotment and `-Xmx` will follow 80-90% of the limits memory allotment. For the clouddriver example above, the `env` key is as follows:

```
env:
   JAVA_OPTS: "-Xms410m -Xmx819m
```

### Recommendations

It is not recommended that limits and requests be applied to the bootstrapping pods. These pods can be scaled down to 0 once `hal deploy apply` has been completed. They will be relaunched the next time a `hal deploy apply` is executed.