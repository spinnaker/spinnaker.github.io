---
layout: single
title:  "Development Environments for Spinnaker Gardening Days"
sidebar:
  nav: community
---
What's the best environment for Spinnaker development? How can you set up your workstation to debug a Spinnaker service?  It depends! Consider these constraints when choosing your strategy:

* __Locally available computing resources__: Hosting Spinnaker services is memory intensive.
* __Access and cost management for public clouds__: Spinnaker can be hosted in the cloud, but you'll pay for resources.
* __Familiarity with Kubernetes__: You can use Kubernetes tools to manage your Spinnaker environment.

## Install Spinnaker

To develop Spinnaker, you'll need a Spinnaker instance. To get that, you have options:

* Install [Minnaker](https://github.com/armory/minnaker), a Spinnaker instance that runs in a Linux VM on your local machine.
* [Clone and install each Spinnaker service locally](#classic-local-installation-method).
* Install Spinnaker in your Kubernetes cluster that runs in your cloud provider or private cloud of choice. Read more about the [Kubernetes & Docker method](#kubernetes-and-docker-method).

### Minnaker method

If you're not sure which method to choose, we suggest using [[Minnaker](https://github.com/armory/minnaker). This simplifies installation steps and uses lightweight Kubernetes [(K3S)](https://k3s.io/) under the hood. Install in a local Ubuntu 18.04 VM.

The [Test a Pipeline Stage Plugin](/guides/developer/plugin-creators/deck-plugin/) guide contains instructions for setting up a local development environment with Minnaker running in a Multipass VM. This method does not require port-forwarding or setting up remote SSH.

Alternately, you can watch "Developing for Spinnaker With Minnaker (15m 26s)". Learn how to install Minnaker, set up remote SSH, and connect to the local VM instance through local Spinnaker service configuration. Use `kubectl` port forwarding to connect a local clone of Orca to Redis and Front50 in Minnaker. Test and debug Orca by setting a breakpoint in the stage task and running the stage.

<iframe width="560" height="315" src="https://www.youtube.com/embed/xSZlWf9rUI4" frameborder="0" allowfullscreen></iframe>


### AWS EKS and Telepresence method

See the [New Spinnaker Contribution Walkthrough Session](/community/gardening/spin-contrib/) doc for how to use the Telepresence network proxy to enable services running locally to connect to services running in an AWS EKS cluster. You could adapt this method if you want to run Minnaker in a remote VM.

### Classic local installation method

Follow the [Getting Set Up](/guides/developer/getting-set-up/) guide to install Spinnaker locally.

### Kubernetes and Docker method

_The instructions for this method are in beta. Pull requests welcome!_

1. Install Spinnaker to a Kubernetes cluster. There are several ways to do this:
   - [Install Halyard in Docker](/setup/install/halyard/#install-halyard-on-docker)
     - In your `docker run` command, mount the `.kube` directory to the container to allow you to modify `.kube` config files on your local machine and persist the changes inside the container:
       ```
       docker run -p 8084:8084 -p 9000:9000 \
         --name halyard --rm \
         -v ~/.hal:/home/spinnaker/.hal \
         -v ~/.kube:/home/spinnaker/.kube \
         -it \
         gcr.io/spinnaker-marketplace/halyard:stable
       ```
   - Use the [Spinnaker for Google Cloud Engine](https://cloud.google.com/docs/ci-cd/spinnaker/spinnaker-for-gcp) solution, which installs Spinnaker to Google Kubernetes Engine.
   - Consult the installation guide for [Amazon Kubernetes Service](https://aws.amazon.com/blogs/opensource/continuous-delivery-spinnaker-amazon-eks/)
   - Use the new [Spinnaker Operator](https://docs.armory.io/spinnaker/operator/#install-operator) to quickly install with `kubectl` commands.
     - Install the Operator in [cluster mode](https://docs.armory.io/spinnaker/operator/#installing-operator-in-cluster-mode)
     - Front50 won't start up successfully until you point Spinnaker to persistent storage, such as an S3 bucket. Update `deploy/spinnaker/basic/SpinnakerService.yml` as in this snippet:
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

2. Open a bash shell in the location where Halyard is installed.
  - If Halyard is running in Docker, run `docker exec -it halyard bash` to enter a shell.   
3. Edit the Kubernetes block of your `.hal/config` with your namespace and kubeconfig file location to enable a Kubernetes install:
  ```
  ...
  kubernetes:
    enabled: true
    accounts:
      name: kubernetes
      requiredMembership: []
      permissions: []
      dockerRegistries: []
      configureImagePullSecrets: true
      cacheThreads: 1
      namespaces:
        - <namespace>
      omitNamespaces: []
      kinds: []
      omitKinds: []
      customResources: []
      cachingPolicies: []
      kubeconfigFile: </path/to/kubeconfig/>
      oAuthScopes: []
      onlySpinnakerManaged: false
    primaryAccount: kubernetes
      ...
  ```
4. Port-forward the externally-hosted Spinnaker services to your local machine.
  - You may use [NGROK](https://ngrok.com/download)
  - Or, try this Fish function: `pf-spinnaker`, which loops through all of the Spinnaker services in your Kubernetes namespaces and forwards their ports to your local machine. Try it:
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
  To tear down these port forwards (for example, when restarting a service), run this function from the same terminal that issued `pf-spinnaker`:
  ```
  function kill-background
    jobs | tail -n"+1" | awk -F\  '{print $2}' | xargs -I"{}" kill "{}"
  end
  ```
5. Git clone the [Spinnaker service(s)](https://github.com/spinnaker) you will debug or extend.
6. Hack!
7. When you're ready to run integration tests, create a docker image with your local build. Read more [in this blog](https://aetas.pl/posts/2019-11-21-docker-image-with-gradle/).
8. Tag the image and push it to Docker Hub, Artifactory, Docker Registry, or another artifact store.
9. Edit the [service settings](https://www.spinnaker.io/reference/halyard/custom/#custom-service-settings) for your profile, in `~/.hal/<profileName>/service-settings/<serviceName>.yml`, e.g. `~/.hal/default/service-settings/echo.yml` to pull the container image into your Spinnaker instance:
  ```
  artifactId:
  kubernetes:
    imagePullSecrets:
      - artifactory-creds
  ```
  Include image pull secrets if the container is in a private repository like Artifactory.
10. Run `hal deploy apply` inside the Halyard container to deploy your modified version of the service.
  - If using the `pf-spinnaker` Fish function to port-forward, run the `kill-background` function and then re-reun `pf-spinnaker` each time you restart a service.

__Now you're ready to run and debug the service or services!__

### Additional references

* [This repository](https://github.com/robzienert/spinnaker-oss-setup) installs all Spinnaker dependencies besides the JDK to your machine running OSX. With a few tweaks and a package manager swap, you could also use it to automate dependency setup on Linux.

## Help us improve the contributor experience
This page is beta! Please submit a Pull Request.
