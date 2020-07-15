---
layout: single
title: "Test a Pipeline Stage Plugin"
sidebar:
  nav: guides
---

{% include alpha version="1.20.6" %}

{% include toc %}

This guide explains how to set up a local Spinnaker environment on your Mac or Windows environment so you can test the `pf4jStagePlugin`, which has both Orca and Deck components. Spinnaker services running locally communicate with the other Spinnaker services running in a local VM. Although this guide is specific to the `pf4jStagePlugin`, you can adapt its contents to test your own plugin.

Software for development:

* [Java Development Kit](https://adoptopenjdk.net/), 11
* [Groovy](https://groovy-lang.org/), 3.0.3
* [Gradle](https://gradle.org/install/)
* [Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable) for building and running Deck
* [Multipass](https://multipass.run/), 1.3.0
* [IntelliJ IDEA](https://www.jetbrains.com/idea/), 2020.1.2, with the JetBrains Kotlin plugin
* [Spinnaker](https://www.spinnaker.io/community/releases/versions/) 1.20.6 and [Halyard](https://console.cloud.google.com/gcr/images/spinnaker-marketplace/GLOBAL/halyard) 1.36.0, installed using [Minnaker](https://github.com/armory/minnaker), 0.0.20

Specific to this guide:

* [Orca](https://github.com/spinnaker/orca/tree/release-1.20.x), branch `release-1.20.x`
* [Deck](https://github.com/spinnaker/deck/tree/release-1.20.x), branch `release-1.20.x`
* [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin), v1.1.14

Spinnaker setup used in this guide:

* OSX or Windows using IP {my-workstation-ip} and the VM using {my-vm-ip}
* Orca running on `{my-workstation-ip}:8083`
* Deck running on `{my-workstation-ip}:9000`
* All other services running in the VM on {my-vm-ip}

## Prerequisites

* You have read the [Plugin Creators Guide Overview](/guides/developer/plugin-creators/overview/)
* Your workstation has at least 16GB of RAM and 30GB of available storage
* You have installed JDK 11; see [AdoptOpenJDK](https://adoptopenjdk.net/installation.html#x64_mac-jdk) for installation instructions or install using [Homebrew](https://github.com/AdoptOpenJDK/homebrew-openjdk)
* You have installed Groovy
* You have installed Multipass
* You have installed IntelliJ and the Kotlin plugin
* You know how to run and debug an application using IntelliJ

## Install Spinnaker in a Multipass VM

 Minnaker is an open source tool that installs the latest release of Spinnaker and Halyard on [Lightweight Kubernetes (K3s)](https://k3s.io/).

1. Launch a Multipass VM with 2 cores, 10GB of memory, 30GB of storage.

   ```bash
   multipass launch -c 2 -m 10G -d 30G
   ```

1. Get the name of your VM.

   ```bash
   multipass list
   ```

1. Access your VM.

   ```bash
   multipass shell <vm-name>
   ```

1. Download and unpack Minnaker.

   ```bash
   curl -LO https://github.com/armory/minnaker/releases/download/0.0.20/minnaker.tgz
   tar -xzvf minnaker.tgz
   ```

1. Install Spinnaker.

   The `minnaker/scripts` directory contains multiple scripts. Use the `no_auth_install` script to install Spinnaker in no-auth mode so you can access Spinnaker without credentials. **Be sure to use the `-o` option** to install the open source version of Spinnaker rather than Armory Spinnaker.

   ```bash   
   ./minnaker/scripts/no_auth_install.sh -o
   ```

   If you accidentally forget the `-o` option, run `./minnaker/scripts/switch_to_oss.sh` to install open source Spinnaker.

   The script prints out the IP address of Minnaker after installation is complete.

   Check pod status:

   ```bash
   kubectl -n spinnaker get pods
   ```

   Consult the Minnaker [README](https://github.com/armory/minnaker/blob/master/readme.md#changing-your-spinnaker-configuration) for basic troubleshooting information if you run into issues.

1. Revert Spinnaker to 1.20.6.

   Minnaker forwards `hal` commands to the Halyard pod so you don't need to access the pod itself.

   ```bash
	hal config version edit --version 1.20.6
	hal deploy apply
	```

1. Configure Minnaker to listen on all ports.

   ```bash
   ./minnaker/scripts/utils/expose_local.sh
   ```

   This creates a load balancer for each service. Console output is similar to:

	```bash
	NAME                                READY   STATUS    RESTARTS   AGE
   minio-0                             1/1     Running   0          18h
   mariadb-0                           1/1     Running   0          18h
   halyard-0                           1/1     Running   0          18h
   spin-redis-664df6f896-b5px8         1/1     Running   0          18h
   svclb-spin-clouddriver-lcmrq        1/1     Running   0          10m
   svclb-spin-redis-24qf6              1/1     Running   0          10m
   svclb-spin-front50-8hchk            1/1     Running   0          10m
   svclb-spin-orca-9t89s               1/1     Running   0          10m
   svclb-spin-gate-gn6g5               1/1     Running   0          10m
   svclb-spin-deck-26vpf               1/1     Running   0          10m
   svclb-spin-echo-s6zdv               1/1     Running   0          10m
   svclb-spin-rosco-qwfhv              1/1     Running   0          10m
   spin-deck-55b88d5fb9-v2ngf          1/1     Running   0          10m
   spin-front50-8fd4f9459-fwpzc        1/1     Running   0          10m
   spin-rosco-6885b6df45-jqkl9         1/1     Running   0          10m
   spin-gate-75df95744b-7zvp5          1/1     Running   0          10m
   spin-orca-766f9bbf7b-cw9f7          1/1     Running   0          10m
   spin-echo-9bbcd9df8-td4rt           1/1     Running   0          10m
   spin-clouddriver-55bc94ddcc-4d7cd   1/1     Running   0          10m
	```

## Configure Minnaker for local external services

Decide which Spinnaker services you want to run locally. This example uses Orca and Deck.

Configure Minnaker to expect the relevant services to be external:

```bash
./minnaker/scripts/utils/external_service_setup.sh orca deck
```

Output is similar to:

```bash
Generated deploymentConfigurations[0].deploymentEnvironment.customSizing:
spin-orca:
  replicas: 0
spin-deck:
  replicas: 0
Generated local /etc/spinnaker/.hal/default/profiles/spinnaker-local.yml:
--------------
services:
  orca:
    baseUrl: {my-vm-ip}:8083
  deck:
    baseUrl: {my-vm-ip}:9000
--------------
Place this file at '~/.spinnaker/spinnaker-local.yml' on your workstation
--------------
services:
  clouddriver:
    baseUrl: {my-workstation-ip}:7002
  redis:
    baseUrl: {my-workstation-ip}:6379
  front50:
    baseUrl: {my-workstation-ip}:8080
  orca:
    host: 0.0.0.0
  gate:
    baseUrl: {my-workstation-ip}:8084
  deck:
    host: 0.0.0.0
  echo:
    baseUrl: {my-workstation-ip}:8089
  rosco:
    baseUrl: {my-workstation-ip}:8087
--------------
```

This script creates a `spinnaker-local.yml` on the VM that indicates the IPs where Orca and Deck are running. Furthermore, the script generates Spinnaker configuration content that you need to copy on your OSX workstation. This content tells your locally running services where the rest of the Spinnaker services are running.

**Note**: `external_service_setup.sh` removes the previous configuration each time you run it.

## Configure your workstation for the local services

Copy the `services` section between the dotted lines in the terminal output from the executing the `external_service_setup.sh` script. Create or edit the `~/.spinnaker/spinnaker-local.yml` file on your workstation and paste the previously copied `services` snippet into it.

The `spinnaker-local.yml` has this content:

```yaml
services:
  clouddriver:
    baseUrl: {my-workstation-ip}:7002
  redis:
    baseUrl: {my-workstation-ip}:6379
  front50:
    baseUrl: {my-workstation-ip}:8080
  orca:
    host: 0.0.0.0
  gate:
    baseUrl: {my-workstation-ip}:8084
  deck:
    host: 0.0.0.0
  echo:
    baseUrl: {my-workstation-ip}:8089
  rosco:
    baseUrl: {my-workstation-ip}:8087
--------------
```

## Clone the plugin and required services

Clone the Orca and Deck `release-1.20.x` branches that correspond to the Spinnaker 1.20.6 version you installed using Minnaker.  Then clone `pf4jStagePlugin` v1.1.14, which works with Spinnaker 1.20.6.

```bash
git clone --single-branch --branch v1.1.14 https://github.com/spinnaker-plugin-examples/pf4jStagePlugin.git
git clone --single-branch --branch release-1.20.x https://github.com/spinnaker/orca.git
git clone --single-branch --branch release-1.20.x https://github.com/spinnaker/deck.git
```

## Run Orca in IntelliJ

1. Open the Orca project in IntelliJ.

   * If you don't have a project open, you see a **Welcome to IntellJ IDEA** window.
      1. Click **Open or Import**
      1. Navigate to your Orca directory
      1. Click on `build.gradle` and click **Open**
      1. Select **Open as Project**

   * If you already have one or more projects open, do the following:
      1. Use the menu **File** > **Open**
      1. Navigate to your Orca directory
      1. Click on `build.gradle` and click **Open**
      1. Select **Open as Project**

1. Grab a beverage and snack while you wait for IntelliJ to finish indexing the project.

1. If you have multiple JDKs installed, configure the Orca project to use JDK 11.

Through the next few steps, if you see an `Unable to find Main` log message or fields are grayed out, reimport the project:

   1. **View** > **Tool Windows** > **Gradle**
   1. In the Gradle window, right click "Orca" and then click **Reimport Gradle Project**

1. Create a **Run Configuration**.

   You can skip the following steps if IntelliJ automatically creates a "Main" Run Configuration. Rename "Main" to "RunOrca".

   1. Click the **Add Configuration** or **Edit Configurations** button to open the **Run/Debug Configurations** window.

	  ![Edit Run Configuration](/assets/images/guides/developer/plugin-creators/intellij-edit-runconfig.jpg)

   1. Click the `+` button to create a new configuration.
   1. Select **Application**.
   1. Enter "RunOrca" in the **Name** field.
   1. **Main class**  Click the **...** button.  Wait for the list to load and then select `Main (com.netflix.spinnaker.orca)`. Alternately, click on **Project** and navigate to `orca > orca-web > src > main > groovy > com.netflix.spinnaker > orca > Main`.
   1. In the dropdown for **Use classpath of module**, select **orca-web_main**
   1. Click **Apply** and then **OK**.

	![Run Orca Configuration](/assets/images/guides/developer/plugin-creators/run-orca-config.png)

1. Run `orca` using the `RunOrca` configuration.

   Success output is similar to:

	```bash
	INFO 18111 --- [main] com.netflix.spinnaker.orca.Main: [] Started Main in 11.123 seconds (JVM running for 11.933)
	```

	If Orca can't find Redis, make sure your Minnaker VM is running and that all the Spinnaker services are ready.

	You can stop running Orca after you have verified that you can successfully run it.

## Build the plugin

Navigate to the `pf4jStagePlugin` directory and execute:

```bash
./gradlew releaseBundle
```

The build process creates files you need in later steps:

* `random-wait-orca/build/Armory.RandomWaitPlugin-orca.plugin-ref`
* `random-wait-deck/build/dist/index.js`

## Configure Orca for the plugin

1. Create a top-level `plugins` directory in your Orca project.
1. Copy the `Armory.RandomWaitPlugin-orca.plugin-ref` file to the `plugins` directory.
1. Create the `orca-local.yml` file in `~/.spinnaker/` with the following contents:

   ```yaml
   spinnaker:
     extensibility:
       plugins:
         Armory.RandomWaitPlugin:
          enabled: true
          version: 1.1.14
          extensions:
            armory.randomWaitStage:
              enabled: true
              config:
                defaultMaxWaitTime: 20
	```

   This tells Spinnaker to enable and use the plugin.

## Import the pf4jStagePlugin project into IntelliJ

1. In IntelliJ, link the `pf4jStagePlugin` project to your Orca project.

   1. Open the **Gradle** window in your Orca project if it's not already open (**View > Tool Windows > Gradle**).
   1. In the **Gradle** window, click the **+** sign to link your `pf4jStagePlugin` Gradle project.
   1. Navigate to your `pf4jStagePlugin` directory , select the `build.gradle` file, and click **Open**.

1. In the **Gradle** window, right click **orca** and click **Reimport Gradle Project**.

You can now run or debug Orca and the plugin using IntelliJ.

## Configure Deck for the plugin

1. Update the `deck/plugin-manifest.json` with the plugin information.

   ```json
	[
		{
			"id": "Armory.RandomWaitPlugin",
			"url": "./plugins/index.js",
			"version": "1.1.14"
		}
	]
	```

	For development, the values in `id` and `version` can be any value.

1. Create a `deck/plugins` directory and `symlink` `random-wait-deck/build/dist/index.js` to `deck/plugins/index.js`. For example:

   ```bash
   cd <path-to-deck>
   ln -s <path-to-pf4jStagePlugin>/random-wait-deck/build/dist/index.js plugins/index.js
	```

## Run the plugin and Orca in IntelliJ

1. Create a new build configuration.

   1. Click **Edit Configurations...**
   1. In the **Run/Debug Configurations** window, click the **+** icon and then select **Application**.
   1. Fill in fields 1-6 with the following:

	  1. **Name:** "Build and Test Plugin"
	  2. **Main class:** "com.netflix.spinnaker.orca.Main"
	  3. **VM options:** "-Dpf4j.mode=development"
	  4. **Use classpath of module:** "orca-web_main"
	  5. **JRE:** 11
	  6. **Before launch** Build Project (remove Build)

     ![Create Run Configuration](/assets/images/guides/developer/plugin-creators/build-test-runconfig.jpg)

   1. Click **OK**.

1. Run `orca` and the `pf4jStagePlugin` using the **Build and Test Plugin**  configuration. On successful launch, you see a "Completed initialization" log statement in the console:

   ```bash
	020-05-12 16:03:44.274  INFO 6973 --- [0.0-8083-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : [] Initializing Spring DispatcherServlet 'dispatcherServlet'
   INFO 6973 --- [0.0-8083-exec-1] o.s.web.servlet.DispatcherServlet        : [] Initializing Servlet 'dispatcherServlet'
   INFO 6973 --- [0.0-8083-exec-1] o.s.web.servlet.DispatcherServlet        : [] Completed initialization in 16 ms
	```

   If you see error messages about Redis, make sure all the pods in your Spinnaker instance are `READY`. You can check the IP address and port for each service in `~/.spinnaker/spinnaker-local.yml`.

	Plugin loading messages appear near the top of the Orca log. You should see statements similar to:

	```bash
   INFO 90843 --- [main] org.pf4j.AbstractPluginManager: [] Plugin 'Armory.RandomWaitPlugin@unspecified' resolved
   INFO 90843 --- [main] org.pf4j.AbstractPluginManager: [] Start plugin 'Armory.RandomWaitPlugin@unspecified'
   INFO 90843 --- [main] i.a.p.s.wait.random.RandomWaitPlugin: [] RandomWaitPlugin.start()
	```

## Build and run Deck

The Deck project [README](https://github.com/spinnaker/deck) has instructions for building and running Deck locally.

1. Build Deck by executing `yarn` from the `deck` directory.
2. Start Deck with the API_HOST argument, which is the Gate URL.

   ```bash
   cd deck
   yarn
   API_HOST={my-workstation-ip}:8084 yarn start
	```

## Verify the plugin loads in Deck

1. Access the the Spinnaker UI at `http://localhost:9000`.
1. Go to **Applications** > **spin** > **PIPELINES**.
1. Create a new pipeline.
1. Add a new stage.
1. Look for "Random Wait" in the **Type** select list.

### Troubleshooting

You can use the Developer Tools in your browser to troubleshoot Deck plugin issues.

![Debugging Deck in Chromium](/assets/images/guides/developer/plugin-creators/debugDeck01.png)

Look for `plugin-manifest.json` and `index.js`. It's normal to see 3 `plugin-manifest.json` HTTP requests. The first one is from Deck - you created this file in the [Configure Deck for the plugin](#configure-deck-for-the-plugin) section above. The next two from Gate are not relevant for local development. If you don't see the `plugin-manifest.json` and `index.js` HTTP requests, check the **Console** tab for errors. Also verify that the content in your `plugin-manifest.json` file is correct.

## Debug the backend of the plugin

If you want to debug the backend component of the plugin without a working Deck component, you can create a new stage in the UI and configure it using JSON.

1. Start the **Build and Test Plugin** configuration in Debug mode.
1. Start Deck.
1. Access the the Spinnaker UI at `http://localhost:9000`.
1. Go to **Applications** > **spin** > **PIPELINES**.
1. Create a new pipeline.
1. Add a new stage.
1. Do not choose a stage from the **Type** select list. Instead, click **Edit stage as JSON** to open the **Edit Stage JSON** window.
1. Paste this content in the text box:

   ```json
   {
     "maxWaitTime": 15,
     "name": "Test RandomWait",
     "type": "randomWait"
    }
   ```

   * `maxWaitTime`: number of seconds; you get the `maxWaitTime` field name from the variable passed into the `RandomWaitInput` [primary constructor](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/blob/master/random-wait-orca/src/main/kotlin/io/armory/plugin/stage/wait/random/RandomWaitInput.kt)
	* `name`: name of the new stage
	* `type`: use the value returned by the [`getName` function](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/blob/master/random-wait-orca/src/main/kotlin/io/armory/plugin/stage/wait/random/RandomWaitPlugin.kt#L40) in `RandomWaitStage`

1. Click **Update Stage**.
1. Click **Save Changes**.
1. Go back to the **PIPELINES** screen.
1. **Start Manual Execution** and watch the stage wait for the specified number of seconds.


## Resources

You can ask for help with plugins in the [Spinnaker Slack's](https://join.spinnaker.io/) `#plugins` channel.

