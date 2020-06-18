---
layout: single
title:  "Development Environments for Spinnaker Gardening Days"
sidebar:
  nav: community
---
What's the best environment Spinnaker development? How can you set up your workstation to debug a Spinnaker service?  It depends! Consider these constraints when choosing your strategy:

* __Locally available computing resources__: hosting Spinnaker services is memory intensive.
* __Access and cost management for public clouds__: Spinnaker can be hosted in the cloud, where you'll pay for resources.
* __Familiarity with Kubernetes__: you may use Kubernetes tools to manage your Spinnaker environment if you prefer.

# Install Spinnaker
First things first, to develop Spinnaker, you'll need a Spinnaker instance. To get that, you have options:
* Install [Minnaker](https://github.com/armory/minnaker), a POC Spinnaker instance that runs in a Linux VM on your local machine, or in the cloud.
* [Clone and install each Spinnaker service locally.](#classic-local-installation-method)
* [Install Spinnaker to your Kubernetes cluster](#kubernetes-installation-methods), running in your cloud provider or private cloud of choice. Read more about the [Kubernetes & Docker method](#kubernetes-and-docker-method) below.

## Minnaker method
If you're not sure which method to choose, we suggest following [these instructions to install Minnaker](https://github.com/armory/minnaker) in your chosen environment. This simplifies installation steps, and uses lightweight Kubernetes [(K3S)](https://k3s.io/) under the hood. Install in a cloud VM or a local Ubuntu 18.04 VM.

### <a href="https://youtu.be/xSZlWf9rUI4" target="_blank">Developing for Spinnaker With Minnaker (15m 26s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/embed/xSZlWf9rUI4" frameborder="0" allowfullscreen></iframe>

_Learn how to install Minnaker, set up remote SSH, and connect to the local VM instance via local Spinnaker service configuration. Use kubectl port forwarding to connect a local clone of Orca to Redis and Front50 in Minnaker. Test and debug Orca by setting a break point in the stage task and running the stage._

### Set up local development environment
1. Install your IDE. These instructions target [IntelliJ IDEA](https://www.jetbrains.com/idea/download/#section=mac).
2. Git clone the [Spinnaker service(s)](https://github.com/spinnaker) you will debug or extend.
3. Open the project in your IDE: File > Open > Select project folder > Click 'OK'.
4. Build the project:
   - Open the 'Gradle' window and double-click the 'Build' task under Tasks > Builds. (If you don't see the 'Gradle' window, select View > Tool Windows > Gradle to open it.)

#### __Next steps IF your Minnaker instance is running in the cloud__

5. [Install NGROK](https://ngrok.com/download), a tunneling service. Run it to create a tunnel from the service to the Spinnaker instance:
   - Consult the [port mappings reference](/reference/architecture/#port-mappings) to determine which ports to forward. Create tunnels for the service(s) you're running locally.
   - Execute `ngrok http <service port number>` e.g. `ngrok http 8089` for echo.
   - Copy the URL in the `Forwarding` output lines.
6. Configure your Spinnaker instance to use the forwarded NGROK address(es).
   - Create a `.hal/default/profiles/spinnaker-local.yml` file.
   - Add service settings, or copy settings from `.hal/default/staging/spinnaker.yml` and delete unnecessary services. Read more on [custom service settings](/reference/halyard/custom/#custom-service-settings).
   - Change the `baseURL` for the service to the copied NGROK endpoint.
7. Configure the local service to communicate with the Spinnaker instance.
   - Copy the kubeconfig from Spinnaker `/etc/spinnaker/.kube/config` to your local machine (e.g. `/tmp/kubeconfig-minnaker`)
   - Update the kubeconfig clusters.cluster.server address to point to the external endpoint URL as in this snippet:

    ```
    apiVersion: v1
      clusters:
      - cluster:
          server: ec2-34-223-57-141.us-west-2.compute.amazonaws.com:6443
    ...
    ```
   - Make sure the security group on your VM allows port 6443.
   - Use `kubectl port-forward` to forward the services required. For example, if running echo locally, you'll need it to communicate with orca and front50:
  ```
  kubectl --kubeconfig config-minnaker -n spinnaker port-forward spin-orca-5f47b76f84-bvh98 8083:8083
  kubectl --kubeconfig config-minnaker -n spinnaker port-forward spin-front50-64ddf796bf-gznqj 8080:8080
  ```
8. __Now you're ready to run and debug the service or services!__

#### __Next steps IF your Minnaker instance is running locally__
5. [Create a kubeconfig for your machine reference](http://docs.shippable.com/deploy/tutorial/create-kubeconfig-for-self-hosted-kubernetes-cluster/).
   - Create a skeleton kubeconfig and get the certificate for the cluster:
   `kubectl config view --flatten --minify`
   - Create a service account for the namespace: `serviceaccount`
   - Copy the token for the secret associated with the serviceaccount `kubectl describe secret`
   - Grant the service account - cluster-admin access `clusterrolebinding`
   - Update the `users.user` section of the `kubeconfig` by replacing `users.user.password` and `users.user.username` to `users.user.token`, where the token value is the secret value associated with the ServiceAccount.
   - Update the kubeconfig `clusters.cluster.server` address to point to the IP address of Minnaker on local machine:  e.g.  `192.168.123.128:6443`
   - Consult this example `kubeconfig` for reference:
    ```

    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: <CAString>
        server: https://192.168.1.128:6443
      name: plugin.example.net
    contexts:
    - context:
        cluster: plugin.example.net
        user: spinnaker-sa
      name: plugin.example.net
    current-context: plugin.example.net
    kind: Config
    preferences: {}
    users:
    - name: spinnaker-sa
      user:
        token: <tokenString>
    ```
6. Configure your Minnaker instance to forward ports to your local machine (gateway) via spinnaker-local.yml configuration.
   - Create a `.hal/default/profiles/spinnaker-local.yml` file.
   - Add service settings, or copy settings from `.hal/default/staging/spinnaker.yml` and delete unnecessary services. Read more on [custom service settings](/reference/halyard/custom/#custom-service-settings).
   - Change the `baseURL` for the service to the default gateway IP Address including the port, e.g. `http://192.168.123.1:8083` for orca.
   - Consult the [port mappings reference](/reference/architecture/#port-mappings) to determine which ports to forward.
7. Configure the local service to communicate with the Spinnaker instance.
   - The `kubeconfig` you just created does part of the configuration.
   - Use `kubectl port-forward` to forward the services required. For example, if running Echo locally, you'll need it to communicate with Orca and Front50:
     - Option 1: Forward via Service:
        `kubectl` `--``kubeconfig config-minnaker -n spinnaker port-forward svc/spin-orca 8083:8083 &`
        `kubectl --kubeconfig config-minnaker -n spinnaker port-forward svc/spin-front50 8080:8080 &`
     - Option 2: Forward via Pod:
        `kubectl --kubeconfig config-minnaker -n spinnaker port-forward spin-orca-5f47b76f84-bvh98 8083:8083`
        `kubectl --kubeconfig config-minnaker -n spinnaker port-forward spin-front50-64ddf796bf-gznqj 8080:8080`
8. __Now you're ready to run and debug the service or services!__

## Classic local installation method
Follow the [Getting Set Up](https://www.spinnaker.io/guides/developer/getting-set-up/) guide to install Spinnaker locally.

## Kubernetes and Docker method:

### Kubernetes installation methods
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
3. Edit the Kubernetes block of your .hal/config with your namespace and kubeconfig file location to enable a Kubernetes install, as in this snippet:
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
4. Port-forward the externally-hosted Spinnaker services to your local machine
  - You may use [NGROK](https://ngrok.com/download)
  - Or, try this Fish function: `pf-spinnaker` loops through all of the Spinnaker services in your Kubernetes namespaces and forwards their ports to your local machine. Try it:
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

## Additional references
* [This repository](https://github.com/robzienert/spinnaker-oss-setup) installs all Spinnaker dependencies besides the JDK to your machine running OSX. With a few tweaks and a package manager swap, you could also use it to automate dependency setup on Linux.

## Help us improve the contributor experience
This page is beta! Please submit a Pull Request.
