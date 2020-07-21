---
layout: single
title:  "New Spinnaker Contribution Walkthrough Session"
sidebar:
  nav: community
---

{% include toc %}

This page contains notes for the _New Spinnaker Contribution Walkthrough_ session. Register for the session on the Gardening Days [schedule](/community/gardening/schedule/).

Registered attendees will receive credentials to access their own Kubernetes namespace on an AWS EKS cluster for the duration of the event.

Attendees are encouraged to use this environment for their hackathon projects as well.

## Session goals

* Use [Spinnaker Operator] to install Spinnaker in your Kubernetes namespace
* Combine tools like [Telepresence] and [kubectl] to modify service locally and interact with your remote cluster
* Get hands on contribution experience by adding a new Pipeline Stage to Spinnaker

## Software

* [IntelliJ IDEA](https://www.jetbrains.com/idea/) Community Edition, which comes bundled with Gradle and Groovy
* [Java Development Kit](https://adoptopenjdk.net/), 11
* [Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable) for building and running Deck
* [kubectl] for managing your Kubernetes cluster
* [Telepresence], a network proxy
* Spinnaker 1.21.x, installed using [Spinnaker Operator]

## Save your Kubernetes config file

The session instructor creates a Kubernetes namespace on EKS for each registered attendee and emails a download link. Save this YAML file to your local `~./kube/` directory. You can name the file anything you'd like, but for this workshop we suggest `garden.yaml`.

_Subsequent steps in this workshop refer to your `kubeconfig` file as `garden.yaml`._

## Install software

* Download and install IntelliJ Community Edition.

  * Install the `EnvFile` plugin to easily import variables into your Run configurations.

* Install [JDK 11](https://adoptopenjdk.net/installation.html).

  * Mac

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

  * Mac

    ```bash
    brew install kubectl
    ```

   * Windows [instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows)

* Install Telepresence.

  * Mac   

    ```bash
    brew cask install osxfuse
    brew install datawire/blackbird/telepresence
    ```

   * Windows [instructions](https://www.telepresence.io/reference/windows)

## Fork and clone Orca and Deck repositories

Fork the repositories in the UI, then clone them to your local machine. Check out the release branch of these services so that we're working against the latest stable version:

```bash
git clone git@github.com:<your-github-username>/orca.git
git clone git@github.com:<your-github-username>/deck.git
cd orca
git checkout release-1.21.x
cd ../deck
git checkout release-1.21.x
```

Import the Orca project into IntelliJ. **File** -> **Open**, select `orca/build.gradle`, and import as a new project. You can continue on with the following steps while IntelliJ imports the project.

You can also build Orca using Gradle on the command line:

```bash
cd orca
./gradlew
```

Build Deck via the command line:

```bash
cd deck
yarn
```

You can ignore the `gyp` not found error when you build Deck.


## Install Spinnaker

Create a repository for yourself based on the [template repository here][tpl].

Use `spinsvc.yml` to deploy Spinnaker on the EKS cluster your instructor set up for you. Download the file. Update the last part of the s3 bucket name on L26 with your `namespace` name. You can find your `namespace` name on L10 of the Kubernetes config that you downloaded [earlier](#save-your-kubernetes-config-file).

```yaml
spec:
  # spec.spinnakerConfig - This section is how to specify configuration spinnaker
  spinnakerConfig:
    # spec.spinnakerConfig.config - This section contains the contents of a deployment found in a halconfig .deploymentConfigurations[0]
    config:
      version: 1.21.0
      persistentStorage:
        persistentStoreType: s3
        s3:
          bucket: gardening-days-FIXME # replace with gardening-days-<your-namespace>
          rootFolder: front50
```

For example, if your `namespace` is "aimee", change `gardening-days-FIXME` to `gardening-days-aimee` in the `s3:bucket` section.

Save the file.

Export your KUBECONFIG file and `kubectl apply` the `spinsvc.yaml` custom resource definition to install Spinnaker. _You only have access to your namespace, so you do not need to include the `-n <namespace>` parameter._

```bash
kubectl --kubeconfig ~/.kube/<kube-config-file-name>.yaml apply -f <spinnaker-service-file>.yaml
```

For example:

```bash
kubectl --kubeconfig ~/.kube/garden.yaml apply -f spinsvc.yaml
```

Check the status of the Spinnaker pods:

```bash
 kubectl --kubeconfig ~/.kube/garden.yaml get pods
 ```

 You should see output similar to the following:

 ```bash
 NAME                                READY   STATUS              RESTARTS   AGE
spin-clouddriver-7fb7bf898d-8cl8r   0/1     Running             0          22s
spin-deck-7dccfc7b78-kvhhw          1/1     Running             0          22s
spin-echo-6785784d68-zpwbz          0/1     Running             0          22s
spin-front50-75dcbc8cf7-jsr4k       0/1     Running             0          22s
spin-gate-85c85856c5-rm7kt          0/1     Running             0          22s
spin-orca-65d4c5848f-qw748          0/1     Running             0          22s
spin-redis-677f644ff-kt6qk          1/1     Running             0          22s
spin-rosco-79b55d5c99-zkq4w         0/1     ContainerCreating   0          22s
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
[tpl]: https://github.com/spinnaker-hackathon/new-spin-contrib-manifest
[kubectl]: https://kubernetes.io/docs/reference/kubectl/overview/
