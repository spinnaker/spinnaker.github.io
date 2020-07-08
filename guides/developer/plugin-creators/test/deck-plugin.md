---
layout: single
title: "Deck Plugin"
sidebar:
  nav: guides
---

{% include_relative alpha-toc.md %}

This guide explains how to set up a local Spinnaker environment on your MacBook so you can test the pf4jStagePlugin, which has both Orca and Deck components. Spinnaker microservices running inside IntelliJ communicate with the other Spinnaker services that are running in a local VM.

Example Spinnaker setup:

* OSX using IP 192.168.64.1 and the VM using 192.168.64.5
* Orca running on `http://192.168.64.1:8083`
* Deck running on `http://192.168.64.1:9000`
* All other services running in VM on 192.168.64.5

{% include_relative software.md %}

Specific to this guide:

* [Orca](https://github.com/spinnaker/orca/tree/release-1.20.x), branch `release-1.21.x`
* [Deck](https://github.com/spinnaker/deck/tree/release-1.20.x), branch `release-1.21.x`
* [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin), v1.1.14

{% include_relative prereqs.md %}

{% include_relative install-minnaker.md %}

## Configure Minnaker for local external services

Decide which Spinnaker services you want to run locally. This example uses Orca and Deck.

Configure Minnaker to expect the relevant service to be external:

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
    baseUrl: http://192.168.64.1:8083
  deck:
    baseUrl: http://192.168.64.1:9000
--------------
Place this file at '~/.spinnaker/spinnaker-local.yml' on your workstation
--------------
services:
  clouddriver:
    baseUrl: http://192.168.64.5:7002
  redis:
    baseUrl: http://192.168.64.5:6379
  front50:
    baseUrl: http://192.168.64.5:8080
  orca:
    host: 0.0.0.0
  gate:
    baseUrl: http://192.168.64.5:8084
  deck:
    host: 0.0.0.0
  echo:
    baseUrl: http://192.168.64.5:8089
  rosco:
    baseUrl: http://192.168.64.5:8087
--------------
```

This script creates a `spinnaker-local.yml` on the VM that indicates the IPs where Orca and Deck are running. Furthermore, the script generates Spinnaker configuration content that you need to copy on your OSX workstation. This content tells your locally running services where the rest of the Spinnaker services are running.

**Note**: `external_service_setup.sh` removes the previous configuration each time you run it.

## Configure your OSX workstation for the local services

Copy the `services` section between the dotted lines in the terminal output from the executing the `external_service_setup.sh` script. Create or edit the `~/.spinnaker/spinnaker-local.yml` file on your workstation and paste the previously copied `services` snippet into it.

## Clone the plugin and required services

For this guide, `pf4jStagePlugin` v1.1.14, which works with Spinnaker 1.21.0. Clone the Orca and Deck `release-1.21.x` branches that correspond to the Spinnaker 1.21.0 version you installed using Minnaker.  

```bash
git clone --single-branch --branch v1.1.14 https://github.com/spinnaker-plugin-examples/pf4jStagePlugin.git
git clone --single-branch --branch release-1.21.x https://github.com/spinnaker/orca.git
git clone --single-branch --branch release-1.21.x https://github.com/spinnaker/deck.git
```

## Run Orca in IntelliJ

1. Open the Orca project in IntelliJ

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

1. Grab a beverage and snack while you wait for IntelliJ to finish indexing the project

1. If you have multiple JDKs installed, configure the Orca project to use JDK 11

Through the next few steps, if you see an `Unable to find Main` log message or fields are grayed out, reimport the project:

   1. **View** > **Tool Windows** > **Gradle**
   1. In the Gradle window, right click "Orca" and then click **Reimport Gradle Project**

1. Create a **Run Configuration**

   You can skip the following steps if IntelliJ automatically creates a "Main" Run Configuration. Rename "Main" to "RunOrca".

   1. Click the **Add Configuration** or **Edit Configurations** button to open the **Run/Debug Configurations** window

	  ![Edit Run Configuration](/assets/images/guides/developer/plugin-creators/intellij-edit-runconfig.jpg)

   1. Click the `+` button to create a new configuration
   1. Select **Application**
   1. Enter "RunOrca" in the **Name** field
   1. **Main class**  Click the **...** button.  Wait for the list to load and then select `Main (com.netflix.spinnaker.orca)`. Alternately, click on **Project** and navigate to `orca > orca-web > src > main > groovy > com.netflix.spinnaker > orca > Main`
   1. In the dropdown for **Use classpath of module**, select **orca-web_main**
   1. Click **Apply** and then **OK**

	![Run Orca Configuration](/assets/images/guides/developer/plugin-creators/run-orca-config.png)

1. Run `orca` using the `RunOrca` configuration

   Success output is similar to:

	```bash
	INFO 18111 --- [           main] com.netflix.spinnaker.orca.Main          : [] Started Main in 11.123 seconds (JVM running for 11.933)
	```

	If Orca is unable to find Redis, make sure your Minnaker VM is running and that all the Spinnaker services are ready.

	You can stop running Orca after you have verified that you can successfully run it.

## Build the plugin

Navigate to the `pf4jStagePlugin` directory and execute:

```bash
./gradlew releaseBundle
```

Building creates files you need in later steps:

* `random-wait-orca/build/Armory.RandomWaitPlugin-orca.plugin-ref`
* `random-wait-deck/build/dist/index.js`

## Configure your local Spinnaker environment for the plugin

1. Create a top-level `plugins` directory in your Orca project
1. Copy the `Armory.RandomWaitPlugin-orca.plugin-ref` file to the `plugins` directory
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

1. In IntelliJ, link the `pf4jStagePlugin` project to your `Orca` project

   1. Open the **Gradle** window in your Orca project if it's not already open (**View > Tool Windows > Gradle**)
   1. In the **Gradle** window, click the **+** sign to link your `pf4jStagePlugin` Gradle project
   1. Navigate to your `pf4jStagePlugin` directory , select the `build.gradle` file, and click **Open**

1. In the **Gradle** window, right click **orca** and click **Reimport Gradle Project**

## Configure Deck for the plugin

1. Update the `deck/plugin-manifest.json` with your plugin information

   ```json
	[
		{
			"id": "Armory.RandomWaitPlugin", // this name doesn't actually matter
			"url": "plugins/index.js"
		}
	]
	```

1. Create a `deck/plugins` directory and `symlink` `random-wait-deck/build/dist/index.js` to `deck/plugins/index.js`. For example:

   ```bash
	cd <path-to-deck>
   ln -s <path-to-pf4jStagePlugin>/random-wait-deck/build/dist/index.js plugins/index.js
	```

## Run the plugin and Orca in IntelliJ

1. Create a new build configuration

   1. Click **Edit Configurations...**
   1. In the **Run/Debug Configurations** window, click the **+** icon and then select **Application**
   1. Fill in fields 1-6 with the following:

	  1. **Name:** "Build and Test Plugin"
	  2. **Main class:** "com.netflix.spinnaker.orca.Main"
	  3. **VM options:** "-Dpf4j.mode=development"
	  4. **Use classpath of module:** "orca-web_main"
	  5. **JRE:** 11
	  6. **Before launch** Build Project (remove Build)

      ![Create Run Configuration](/assets/images/guides/developer/plugin-creators/build-test-runconfig.jpg)

   1. Click **OK**

1. Run `orca` using the `Build and Test Plugin`  configuration. On success, you see a "Completed initialization" log statement in the console:

   ```bash
	020-05-12 16:03:44.274  INFO 6973 --- [0.0-8083-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : [] Initializing Spring DispatcherServlet 'dispatcherServlet'
   INFO 6973 --- [0.0-8083-exec-1] o.s.web.servlet.DispatcherServlet        : [] Initializing Servlet 'dispatcherServlet'
   INFO 6973 --- [0.0-8083-exec-1] o.s.web.servlet.DispatcherServlet        : [] Completed initialization in 16 ms
	```

   If you see error messages about Redis, make sure all the pods in your Spinnaker instance are `READY`. You can check the IP address and port for each service in `~/.spinnaker/spinnaker-local.yml`.

	Plugin loading messages appear near the top of the Orca log. You should see statements similar to:

	```bash
	INFO 90843 --- [           main] org.pf4j.AbstractPluginManager           : [] Plugin 'Armory.RandomWaitPlugin@unspecified' resolved
   INFO 90843 --- [           main] org.pf4j.AbstractPluginManager           : [] Start plugin 'Armory.RandomWaitPlugin@unspecified'
   INFO 90843 --- [           main] i.a.p.s.wait.random.RandomWaitPlugin     : [] RandomWaitPlugin.start()
	```

## Build and run Deck

The Deck project [README](https://github.com/spinnaker/deck) has instructions for building and running Deck locally.

1. Build Deck by executing `yarn` from the `deck` directory
2. Start Deck with the API_HOST argument, which is the Gate URL

   ```bash
	cd deck
	yarn
   API_HOST=http://192.168.64.5:8084 yarn start
	```

## Test the plugin

1. Access the the Spinnaker UI at `http://localhost:9000`
1. Go to **Applications** > **spin** > **PIPELINES**
1. Create a new pipeline
1. Add a new stage
1. Click **Edit stage as JSON** to open the **Edit Stage JSON** window
1. Paste this content in the text box:

   ```json
   {
     "maxWaitTime": 15,
     "name": "Test RandomWait",
     "type": "randomWait"
    }
   ```

1. Click **Update Stage**
1. Click **Save Changes**
1. Go back to the **PIPELINES** screen
1. **Start Manual Execution** and watch the stage wait for the specified number of seconds



