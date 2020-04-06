---
layout: single
title:  "Development Environments for Spinnaker Gardening Days"
sidebar:
  nav: community
---
What's the best way to get set up for Spinnaker development? It depends! Consider these constraints when choosing your strategy:

* __Locally available computing resources__: hosting Spinnaker services is memory-intensive.
* __Access and cost management for public clouds__: Spinnaker can be hosted in the cloud, where you'll pay for compute.
* __Familiarity with Kubernetes__: you may use Kubernetes tools to manage your Spinnaker environment if you prefer.

## Minnaker methods
_If you're not sure which method to choose, we suggest trying this method first. It simplifies installation steps considerably, and the guide walks you through installing and configuring an IDE (IntelliJ) to talk to Spinnaker._
* Follow this video guide to install [Minnaker](https://github.com/armory/minnaker), a POC Spinnaker instance that runs in a VM either locally or in the cloud.

## Classic local development method
* Follow the [Getting Set Up](https://www.spinnaker.io/guides/developer/getting-set-up/) guide to install Spinnaker locally.

## Cloud Kubernetes & local method
* Install Spinnaker to a Kubernetes cluster running in your cloud provider or private cloud of choice.
  * Consult installation guides for [Google Kubernetes Engine](https://www.spinnaker.io/setup/quickstart/halyard-gke/) and [Amazon Kubernetes Service](https://aws.amazon.com/blogs/opensource/continuous-delivery-spinnaker-amazon-eks/)
  * Alternatively, use the [Spinnaker Operator](https://docs.armory.io/spinnaker/operator/#install-operator). Install the Operator in [cluster mode](https://docs.armory.io/spinnaker/operator/#installing-operator-in-cluster-mode)
* Port-forward the externally-hosted Spinnaker services to your local machine
  * Try using this Fish function:
  ```
  function pf-spinnaker
    set -l services (string split , -- \
                    (kubectl get services -o json \
                      | jq -r '.items[] | [.metadata.name, .spec.ports[0].port] | @csv'))
    set -l service_length (count $services)
    set -l current_service 1
    while test $current_service -lt $service_length
      set -l service (string replace --all '"' '' -- $services[$current_service])
      set -l port $services[(math $current_service + 1)]
      command kubectl port-forward "service/$service" $port &
      set current_service (math "$current_service+2")
    end
  end
  function kill-background
    jobs | tail -n"+1" | awk -F\  '{print $2}' | xargs -I"{}" kill "{}"
  end
  ```

## Additional tools:

* [This repository](https://github.com/robzienert/spinnaker-oss-setup) will install all Spinnaker dependencies besides the JDK to your machine running OSX. With a few tweaks and a package manager swap, you could also use it to automate dependency setup on Linux.
