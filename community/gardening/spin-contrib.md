---
layout: single
title:  "New Spinnaker Contribution Walkthrough Session"
sidebar:
  nav: community
---

{% include toc %}

This page contains notes for the _New Spinnaker Contribution Walkthrough_ session.
Register for the session on the Spinnaker Summit
[page](https://events.linuxfoundation.org/spinnaker-summit/register/).

Registered attendees will receive credentials to access their own Kubernetes namespace on an AWS EKS cluster for the duration of the event.

Attendees are encouraged to use this environment for their hackathon projects as well.

Below is a recording from a previous workshop that you can use to follow along:

<div style="width: 65%;">
  <iframe width="280" height="158" src="https://www.youtube.com/embed/Sb5CO6RQx_Q" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

## Session goals

* Use [Spinnaker Operator] to install Spinnaker in your Kubernetes namespace
* Combine tools like [Telepresence] and [kubectl] to modify services locally
and interact with your remote Spinnaker cluster
* Get hands on contribution experience by adding a new Pipeline Stage to Spinnaker

## Software

* [IntelliJ IDEA](https://www.jetbrains.com/idea/) Community Edition, which comes bundled with Gradle and Groovy
  * While you may choose an editor of your choice, this walkthrough assumes you are using IntelliJ
* [Java Development Kit](https://adoptopenjdk.net/), 11
* [Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable) for building and running Deck
* [kubectl] for managing your Kubernetes cluster
* [Telepresence], a network proxy
* Spinnaker 1.22.x, installed using [Spinnaker Operator]

## Save your Kubernetes config file

The session instructor creates a Kubernetes namespace in EKS for each registered attendee and provides a download link. Save this YAML file to your local `~./kube/` directory. You can name the file anything you'd like, but for this workshop we suggest `garden.yaml`.
If you are following along at home, use the credentials for your existing cluster.

_Subsequent steps in this workshop refer to your `kubeconfig` file as `garden.yaml`._

## Install software

* Download and install IntelliJ Community Edition.


  * Mac instructions

    ```bash
    brew cask install intellij-idea-ce
    ```

  * Windows [instructions](https://www.jetbrains.com/idea/download/#section=windows)

  * Also install the [`EnvFile` plugin](https://plugins.jetbrains.com/plugin/7861-envfile)
  to easily import variables into your Run configurations.

* Install [JDK 11](https://adoptopenjdk.net/installation.html).

  * Mac instructions

    ```bash
    brew tap AdoptOpenJDK/openjdk
    brew cask install adoptopenjdk11
    ```

   * Windows [instructions](https://adoptopenjdk.net/installation.html#x64_win-jdk)

* Install Yarn (installs Node.js if not installed).

  * Mac [instructions](https://classic.yarnpkg.com/en/docs/install#mac-stable)

    ```bash
    brew install yarn
    ```

  * Windows [instructions](https://classic.yarnpkg.com/en/docs/install#windows-stable)


* Install `kubectl`.

  * Mac instructions

    ```bash
    brew install kubectl
    ```

   * Windows [instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows)

* Install Telepresence.

  * Mac instructions

    ```bash
    brew cask install osxfuse
    brew install datawire/blackbird/telepresence
    ```

   * Windows [instructions](https://www.telepresence.io/reference/windows)

## Fork and clone the Orca and Deck repositories

[Fork the repositories in GitHub][fork], then [clone them to your local machine][clone].
Code for each project is organized into stable release branches, so to work on a
fix for the `1.22` release you would check out the `release-1.22.x` branch for
Orca and Deck. If you want to contribute a fix for a future release, you would
use the `master` branch.

```bash
# Check out the projects
git clone git@github.com:<your-github-username>/orca.git
git clone git@github.com:<your-github-username>/deck.git

# Set each project to the desired release branch
cd orca
git checkout release-1.22.x

cd ../deck
git checkout release-1.22.x
```

Import the Orca project into IntelliJ. **File** -> **Open**, select `orca/build.gradle`, and import as a new project. You can continue on with the following steps while IntelliJ imports the project.

You can also build Orca using Gradle on the command line:

```bash
cd orca
./gradlew build
```

Build Deck via the command line:

```bash
cd deck
yarn
```

You can ignore the `gyp` not found error when you build Deck.


## Install Spinnaker

Create a repository for yourself based on the [template repository here][tpl]
and [clone] it to your local machine.

The main configuration for your Spinnaker is the `SpinnakerService`
manifest. This manifest describes what version of Spinnaker you want to deploy,
specific configuration for each service (e.g. turning on/off feature flags), and
more.

In this workshop, you manage your configuration files using `kustomize`, which is a tool that allows you to combine and modify partial configurations into a complete manifest that you apply to the cluster.

If you are new to `kubectl` and `kustomize`, the `kustomization.yaml` file will
be your main entry point. The referenced files contain partial
configurations that are combined into a single `SpinnakerService` manifest.
For more information on `kustomize`, see the [official documentation][kustomize].
It is not necessary to install `kustomize` separately for this workshop since it is bundled with `kubectl`.

### Choose a version

The first thing you need to change is the version of Spinnaker you want to deploy. Open `spinnakerservice.yml` and find the following snippet of configuration:

```yaml
apiVersion: spinnaker.io/v1alpha2
kind: SpinnakerService
metadata:
  name: spinnaker
spec:
  spinnakerConfig:
    # ------- Main config section, equivalent to "~/.hal/config" from Halyard
    config:
      version: 2.21.0            # Spinnaker version to deploy
# More configuration below this line.
```

In order to change the version of Spinnaker you are using, modify the `version`
key to match a release. At the time of this workshop, `1.22.2` is
the most current version. Replace `2.21.0` in the config above with
`1.22.2`. You can find the most Spinnaker versions on
the [Spinnaker releases page](https://spinnaker.io/community/releases/versions/).

Save the file.

### Update your namespace

You need to make sure that Kustomize knows about your namespace, otherwise the deployment will fail. Open `kustomization.yml` and modify the `namespace` key to match your username. For example, if your username is `workshop-user`, then you would update the file to look like the following example:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: workshop-user

# More configuration below.
```

>Note: If you see a `NOTE` comment about updating ClusterRoleBinding namespaces,
it is safe to ignore for this workshop. You provide your own service account
in a later section.

### Update your Kubernetes Service Account

Clouddriver is the Spinnaker service that interacts with Kubernete to execute your deployments. In order for Clouddriver to function within your development environment, you need to make sure that it is running with the same service account that you are using to access the cluster.

Open the `./accounts/kubernetes/patch-kube.yml` file.

You should see a `namespaces` key inside of the Kubernetes provider config.
Update this value to contain the namespace that you are using for the
workshop. For example, if your namespace is called `workshop-user`, then modify `namespaces` like this:

```yaml
#-----------------------------------------------------------------------------------------------------------------
# Example configuration for adding kubernetes accounts to spinnaker.
#
# Documentation: https://docs.armory.io/docs/spinnaker-user-guides/kubernetes-v2/
#-----------------------------------------------------------------------------------------------------------------
apiVersion: spinnaker.io/v1alpha2
kind: SpinnakerService
metadata:
  name: spinnaker
spec:
  validation:
    providers:
      kubernetes:
        enabled: true    # Default: true. Indicate if operator should do connectivity checks to configured kubernetes accounts before applying the manifest
  spinnakerConfig:
    config:
      providers:
        kubernetes:
          enabled: true
          primaryAccount: spinnaker
          accounts:
          # Account for Spinnaker's own kubernetes cluster (Optional).
          - name: spinnaker
            serviceAccount: true             # When true, Spinnaker will attempt to authenticate against Kubernetes using a Kubernetes service account. This only works when Spinnaker is deployed in the same Kubernetes cluster. Read more about service accounts here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/.
            providerVersion: V2
            permissions: {}
            dockerRegistries: []
            cacheThreads: 1                  # Number of caching agents for this kubernetes account. Each agent handles a subset of the namespaces available to this account. By default, only 1 agent caches all kinds for all namespaces in the account.
            namespaces:
              - workshop-user
            # Additional config below.
```

At the bottom of the file is the `service-settings` configuration
block, which defines the service account name Clouddriver should use. Change the `clouddriver.kubernetes.serviceAccountName` to the name of the service account that you received for this workshop. For example, if your service account is `workshop-user`, then you would change the `serviceAccountName` value to `workshop-user`:

```yaml
    # Needed for Kubernetes accounts of type "serviceAccount: true"
    service-settings:
      clouddriver:
        kubernetes:
          serviceAccountName: workshop-user # <- this should be your service account name.
```

Save the file.

### Configure Minio

Spinnaker requires an object storage provider in order to save things like
application and pipeline configuration. The template repository that you are
using for this workshop provides pre-baked configuration for [Minio](https://min.io/), an S3
compatible object store that can run inside the Kubernetes cluster. You need to create an access key to configure Minio. The template repository you cloned in the [Install Spinnaker](#install-spinnaker) step contains utility shell scripts that can create and manage secrets for you within the cluster.

Change the name of the `./secrets/secrets-example.env` file to
`./secrets/secrets.env`. Then, open `./secrets/secrets.env` and update the
`minioAccessKey` value to any string with more than eight characters. For example:

```config
#-------------------------------------------------------------------------------------------
# Key-value pairs for secrets to store in Kubernetes.
#
# Reference secrets in spinnaker config files like this (not all fields support secrets):
# encrypted:k8s!n:spin-secrets!k:<secret key>
#-------------------------------------------------------------------------------------------

minioAccessKey=somerandomstringlongerthaneightcharacters
# More secrets defined below this line.
```

Save the file.

### Deploy Spinnaker

You are now ready to deploy our cluster. In order to build a complete
`SpinnakerService` configuration and ensure secrets are created, use
the `./deploy.sh` helper script provided with the template repository.
For this command to function throughout the rest of this workshop, export the
`KUBECONFIG` variable to point to your
[workshop credentials file](#save-your-kubernetes-config-file):

```shell
# In BASH and ZSH shells, you can export like so:
export KUBECONFIG=~/.kube/garden.yaml
```

Then, deploy using the helper script. Make sure to specify the `SPIN_FLAVOR`
variable so you install the open source version of Spinnaker:

```shell
SPIN_FLAVOR=oss ./deploy.sh
```

If you see errors running this script, you can also run the `kubectl apply` command manually like this:

```shell
kubectl --kubeconfig ~/.kube/garden.yaml apply -k .
```

Check the status of the Spinnaker pods:

```bash
kubectl --kubeconfig ~/.kube/garden.yaml get pods
```

You see output similar to the following:

```bash
NAME                                READY   STATUS    RESTARTS   AGE
minio-0                             1/1     Running   0          27m
spin-clouddriver-7569597b8b-zbw6c   1/1     Running   0          27m
spin-deck-7777b5d98b-w7bcl          1/1     Running   0          27m
spin-echo-5c9db8d898-b9pkb          1/1     Running   0          27m
spin-front50-59f8695cd5-xtw4c       1/1     Running   0          27m
spin-gate-bfd4c488c-hn45h           1/1     Running   0          27m
spin-orca-784b867dd8-pz6js          1/1     Running   0          27m
spin-redis-6745f98fb9-fxj7l         1/1     Running   0          27m
spin-rosco-5b69d6556-9dgxx          1/1     Running   0          27m
```

## Port forward Gate and Deck services

In your current Terminal window, forward the Deck port:

```bash
kubectl --kubeconfig ~/.kube/garden.yaml port-forward svc/spin-deck 9000
```

Open another Terminal session and forward the Gate port:

```bash
kubectl --kubeconfig ~/.kube/garden.yaml port-forward svc/spin-gate 8084
```

## Start Telepresence for the local Orca service

In a new Terminal session, change to the Orca directory and start Telepresence:

```
cd <path-to-orca-clone>
KUBECONFIG=~/.kube/garden.yaml telepresence --swap-deployment spin-orca --env-file .env-telepresence
```

You may see a permission error on OSX similar to:

```bash
T: Mounting remote volumes failed, they will be unavailable in this session. If you are running on Windows Subystem for Linux then see https://github.com/datawire/telepresence/issues/115, otherwise please report a bug,
T: attaching telepresence.log to the bug report: https://github.com/datawire/telepresence/issues/new
T: Mount error was: mount_osxfuse: the file system is not available (1)
```

You need to allow the app in **System Preferences** -> **Security & Privacy** -> **General**. Then `exit` the Telepresence session and execute the `telepresence` command again.

Upon success, Telepresence creates an `.env-telepresence` file in the directory where you executed the `telepresence` command.

## Copy Spinnaker configs to your local directory

You can see the Spinnaker config files in the Telepresence session:

```bash
ls $TELEPRESENCE_ROOT/opt/spinnaker/config
```

Output:

```bash
orca-local.yml orca.yml       spinnaker.yml
```

Copy those files to your local `~/.spinnaker` directory:

```bash
cp -R $TELEPRESENCE_ROOT/opt/spinnaker/config/ ~/.spinnaker
```

## Run Orca in IntelliJ

1. Click the **Add Configuration** or **Edit Configurations** button to open the **Run/Debug Configurations** window.

   1. Click the `+` button to create a new configuration.
   1. Select **Application**.
   1. Enter "RunOrcaTelepresence" in the **Name** field.
   1. On the **Configuration** tab
      * **Main class**  Click the **...** button.  Wait for the list to load and then select `Main (com.netflix.spinnaker.orca)`. Alternately, click on **Project** and navigate to `orca > orca-web > src > main > groovy > com.netflix.spinnaker > orca > Main`.
      * In the dropdown for **Use classpath of module**, select **orca-web_main**

      ![Run Orca Telepresence configuration](/assets/images/community/gardening/RunOrcaTelepresence.png)

	1. On the `EnvFile` tab

		* Select **Enable EnvFile**
		* Click the **+** sign
		* **Add...** and select **.env file**
		* Add `.env-telepresence`

        ![Add telepresence file](/assets/images/community/gardening/env-file.png)

   1. Click **Apply** and then **OK**.

1. Run `orca` using the `RunOrcaTelepresence` configuration.

	Success output is similar to:

	```bash
	INFO 18111 --- [main] com.netflix.spinnaker.orca.Main: [] Started Main in 11.123 seconds (JVM running for 11.933)
	```

### Troubleshooting

If you can't configure Orca to run in IntelliJ:

* You can try closing the project and deleting any `*.iml` and `.idea` files. Then select  **File** -> **Open** and select the `settings.gradle` file of the project (`orca` directory)

If you see errors about `fiat` when you run Orca:

* Make sure you have `orca-local.yml`, `orca.yml`, and `spinnaker.yml` in your local `.spinnaker` directory. If those files are missing, either you missed the [step](#copy-spinnaker-configs-to-your-local-directory) to copy those files to your local `.spinnaker` directory **or** Telepresence started but didn't have permission to mount a local volume. If you are on OSX and granted permission while Telepresence was running, you need to restart Telepresence and then copy the config files.

If you see errors about Redis when you run Orca:

* Make sure Telepresence has started without permission errors
* Make sure the Redis container is running

   `kubectl --kubeconfig ~/.kube/garden.yaml get pods`


## Create a new stage

You can access code for this section in this
[gist](https://gist.github.com/dogonthehorizon/805db48d7233c2eab5f8215ecc145ec9)

[Spinnaker Operator]: https://github.com/armory/spinnaker-operator
[Telepresence]: https://www.telepresence.io/
[tpl]: https://github.com/armory/spinnaker-kustomize-patches
[kubectl]: https://kubernetes.io/docs/reference/kubectl/overview/
[fork]: https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo
[clone]: https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository
[kustomize]: https://kubernetes-sigs.github.io/kustomize/guides/bespoke/
