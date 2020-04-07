---
layout: single
title:  "Development Environments for Spinnaker Gardening Days"
sidebar:
  nav: community
---
What's the best environment Spinnaker development? How can you set up your workstation to debug a Spinnaker service?  It depends! Consider these constraints when choosing your strategy:

* __Locally available computing resources__: hosting Spinnaker services is memory-intensive.
* __Access and cost management for public clouds__: Spinnaker can be hosted in the cloud, where you'll pay for compute.
* __Familiarity with Kubernetes__: you may use Kubernetes tools to manage your Spinnaker environment if you prefer.

## Install Spinnaker
First things first, to develop Spinnaker, you'll need a Spinnaker instance. To get that, you have options:
* Install [Minnaker](https://github.com/armory/minnaker), a POC Spinnaker instance that runs in a Linux VM on your local machine, or in the cloud.
* [Install Spinnaker to your Kubernetes cluster](#kubernetes-installation-methods), running in your cloud provider or private cloud of choice.
* [Clone and install each Spinnaker service locally.](#classic-local-installation-method)

### Minnaker method
If you're not sure which method to choose, we suggest following [these instructions to install Minnaker](https://github.com/armory/minnaker) in your chosen environment. This simplifies installation steps, and uses Kubernetes (K3S) under the hood.

### Classic local installation method
Follow the [Getting Set Up](https://www.spinnaker.io/guides/developer/getting-set-up/) guide to install Spinnaker locally.

### Kubernetes installation methods
* Install Spinnaker to a Kubernetes cluster
  * Consult installation guides for [Google Kubernetes Engine](https://www.spinnaker.io/setup/quickstart/halyard-gke/) and [Amazon Kubernetes Service](https://aws.amazon.com/blogs/opensource/continuous-delivery-spinnaker-amazon-eks/)
  * Use the new [Spinnaker Operator](https://docs.armory.io/spinnaker/operator/#install-operator) to quickly install with `kubectl` commands.
    * Install the Operator in [cluster mode](https://docs.armory.io/spinnaker/operator/#installing-operator-in-cluster-mode)
    * Front50 won't start up successfully until you point Spinnaker to persistent storage, such as an S3 bucket. Update `deploy/spinnaker/basic/SpinnakerService.yml` as in this snippet:
    ```
    ...
    spinnakerConfig:
      config:
        persistentStorage:
          persistentStoreType: s3
          s3:
            bucket: mybucket
            rootFolder: front50
        version: 2.18.0
    ...
    ```

## Set up local development environment
* Install your IDE. These instructions target [IntelliJ IDEA](https://www.jetbrains.com/idea/download/#section=mac).
* Git clone the [Spinnaker service(s)](https://github.com/spinnaker) you will debug or extend.
* Import the `gradle.properties` file from the root of the service repository into your IDE:
  * Import Project > Select project folder > Select __Gradle__ > Click 'Finish'
* Build the project:
  * Open the 'Gradle' window and double-click the 'Build' task under Tasks > Builds
* [Install NGROK](https://ngrok.com/download), a tunneling service. Run it to create a tunnel from the service to the Spinnaker instance:
  * Consult the [port mappings reference](reference/architecture/#port-mappings) to determine which ports to forward. Create tunnels for the service(s) you're running locally.
  * Execute `ngrok http <service port number>` e.g. `ngrok http 8089` for echo.
  * Copy the URL in the `Forwarding` output lines.
* Configure your Spinnaker instance to use the forwarded NGROK address(es).
  * Create a `.hal/default/profiles/spinnaker-local.yml` file
  * Add service settings, or copy settings from `staging/spinnaker.yml` and delete unnecessary services. Read more on [custom service settings](https://www.spinnaker.io/reference/halyard/custom/#custom-service-settings).
  * Change the `baseURL` for the service to the copied NGROK endpoint.
* Configure the local service to communicate with the Spinnaker instance.
  * Copy the kubeconfig from Spinnaker `/etc/spinnaker/.kube/config` to your local machine (e.g. `/tmp/kubeconfig-minnaker`)
  * Update the kubeconfig clusters.cluster.server address to point to the external endpoint URL as in this snippet:

    ```
    apiVersion: v1
      clusters:
      - cluster:
          server: ec2-34-223-57-141.us-west-2.compute.amazonaws.com:6443
    ...
    ```
  * If using Minnaker, make sure the security group on your VM allows port 6443.
  * Use `kubectl port-forward` to forward the services required. For example, if running echo locally, you'll need it to communicate with orca and front50:
  ```
  kubectl --kubeconfig config-minnaker -n spinnaker port-forward spin-orca-5f47b76f84-bvh98 8083:8083
  kubectl --kubeconfig config-minnaker -n spinnaker port-forward spin-front50-64ddf796bf-gznqj 8080:8080
  ```

__Now you're ready to run or debug the service(s) : )__


## Additional references
* [This repository](https://github.com/robzienert/spinnaker-oss-setup) installs all Spinnaker dependencies besides the JDK to your machine running OSX. With a few tweaks and a package manager swap, you could also use it to automate dependency setup on Linux.

## Help us improve the contributor experience
This page is beta! Please submit a Pull Request, or use the #gardening-feedback channel to share your thoughts on how to improve the Spinnaker contributor experience.


Extra stuff WIP:

* clone service locally
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
