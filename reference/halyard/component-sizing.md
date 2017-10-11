---
layout: single
title:  "Custom Component Sizing"
sidebar:
  nav: reference
redirect_from: /docs/custom-component-sizing
---

{% include toc %}


Within your halconfig you can specify custom sizing for each of your spinnaker components. These custom sizings must be manually added to your halconfig. This feature is supported for the following providers.

## Kuberenetes

Container requests and limits for cpu and memory can be specified in the customSizing section of your halconfig. Note that these sizings will also be applied to any sidecars running along side the container as well. Please see the example for details.

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