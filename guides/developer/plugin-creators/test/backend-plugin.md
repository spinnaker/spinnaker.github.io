---
layout: single
title: "Backend Plugin"
sidebar:
  nav: guides
---

{% include alpha version="1.20" %}
> This guide is a work in progress. Help us improve the content by submitting a pull request!

{% include toc %}

This guide explains how to set up a local Spinnaker environment on your MacBook so you can test your backend plugin. A Spinnaker microservice running inside IntelliJ communicates with the other Spinnaker services that are running in a local VM.

For example:
* OSX using IP 192.168.64.1 and the VM using 192.168.64.2
* Orca running on http://192.168.64.1:8083
* All other services running in VM on 192.168.64.2

{% include_relative software.md %}

Specific to this guide:

* [Orca](https://github.com/spinnaker/orca/), branch `release-1.20.x`
* [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin), 1.1.4

{% include_relative prereqs.md %}

{% include_relative install-minnaker.md %}

## Configure Minnaker for a local external service

Decide which Spinnaker services you want to run locally. This example uses Orca.

Configure Minnaker to expect the relevant service to be external:

```bash
./minnaker/scripts/utils/external_service_setup.sh orca
```

Output is similar to:

```bash
Place this file at '~/.spinnaker/spinnaker-local.yml' on your workstation
--------------
services:
  clouddriver:
	baseUrl: http://192.168.64.2:7002
  redis:
	baseUrl: http://192.168.64.2:6379
  front50:
	baseUrl: http://192.168.64.2:8080
  gate:
	baseUrl: http://192.168.64.2:8084
  deck:
	baseUrl: http://192.168.64.2:9000
  orca:
	host: 0.0.0.0
  echo:
	baseUrl: http://192.168.64.2:8089
  rosco:
	baseUrl: http://192.168.64.2:8087
--------------
```

Copy the `services` section between the dotted lines. You will use this snippet to configure your OSX workstation.

**Note**: `external_service_setup.sh` removes the previous configuration each time you run it. If you want to run multiple services locally, specify them delimited by a space:

```bash
./minnaker/scripts/utils/external_service_setup.sh orca deck
```

## Configure your OSX workstation for the local service

Create or edit the `~/.spinnaker/spinnaker-local.yml` file and paste the previously copied `services` snippet into it.

## Run a Spinnaker service in IntelliJ

In this example, you use the Orca branch that corresponds to the Spinnaker 1.20 version you installed using Minnaker.

1. Clone the service you need to test your plugin

   ```bash
   git clone --single-branch --branch release-1.20.x https://github.com/spinnaker/orca.git
   ```

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

1. Create a Run Configuration

   1. Click the **Add Configuration** button to open the **Run/Debug Configurations** window
   1. Click the `+` button to create a new configuration
   1. Select **Application**
   1. Enter "RunOrca" in the **Name** field
   1. **Main class**  Click the **...** button.  Wait for the list to load and then select `Main (com.netflix.spinnaker.orca)`. Alternately, click on **Project** and navigate to `orca > orca-web > src > main > groovy > com.netflix.spinnaker > orca > Main`
   1. In the dropdown for **Use classpath of module**, select **orca-web_main**
   1. Click **Apply** and then **OK**

1. Run `orca` using the `RunOrca` configuration

   Success output is similar to:

	```bash
	INFO 18111 --- [           main] com.netflix.spinnaker.orca.Main          : [] Started Main in 11.123 seconds (JVM running for 11.933)
	```

	If Orca is unable to find Redis, make sure your Minnaker VM is running and that all the Spinnaker services are ready.

## pf4jStagePlugin

To show how to deploy and debug a plugin, this guide uses the [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin), which creates a custom pipeline stage that waits a number of seconds before signaling success. The plugin consists of a `random-wait-orca` [Kotlin](https://kotlinlang.org/docs/reference/) server component and a `random-wait-deck` [React](https://reactjs.org/) UI component.

This is a very simplistic plugin for educational purposes only. You can use this plugin as a starting point to create a custom pipeline stage.

### Clone the codebase

```bash
git clone --single-branch --branch v1.1.4 https://github.com/spinnaker-plugin-examples/pf4jStagePlugin.git
```

If you plan to Clone the 1.1.4 tag
Follow the "debugging" section here: https://github.com/spinnaker-plugin-examples/pf4jStagePlugin

notes:
* Create the `plugins` directory in the git repo (e.g., `~/git/spinnaker/orca/plugins`) and put the `.plugin-ref` in there
* If you don't see the gradle tab, you can get to it with View > Tool Windows > Gradle

### Build the plugin

```bash
./gradlew releaseBundle
```

This creates `/build/distributions/pf4jStagePlugin-1.1.4.zip` and `random-wait-orca/build/Armory.RandomWaitPlugin-orca.plugin-ref`.

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
          version: 1.1.4
          extensions:
            armory.randomWaitStage:
              enabled: true
              config:
                defaultMaxWaitTime: 60
	```

   This tells Spinnaker to enable and use the plugin.


## Run the plugin and Orca in IntelliJ

1. In IntelliJ, link the `pf4jStagePlugin` project to your `Orca` project

   1. Open the **Gradle** window in your Orca project if it's not already open (**View > Tool Windows > Gradle**)
   1. In the **Gradle** window, click the **+** sign to link your `pf4jStagePlugin` Gradle project
   1. Navigate to your `pf4jStagePlugin` directory , select the `build.gradle` file, and click **Open**

1. In the **Gradle** window, right click **orca** and click **Reimport Gradle Project**
1. Create a new build configuration

   ![Edit Run Configuration](/assets/images/guides/developer/plugin-creators/intellij-edit-runconfig.jpg)

   1. Click **Edit Configurations...**
   1. In the **Run/Debug Configurations** window, click the **+** icon and then select **Application**
   1. Fill in fields 1-6 like this:

      ![Create Run Configuration](/assets/images/guides/developer/plugin-creators/build-test-runconfig.jpg)

   1. Click **OK**

1. Run `orca` using the `Build and Test Plugin`  configuration. On success, you see a "Completed initialization" log statement in the console

   ```bash
	020-05-12 16:03:44.274  INFO 6973 --- [0.0-8083-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : [] Initializing Spring DispatcherServlet 'dispatcherServlet'
2020-05-12 16:03:44.274  INFO 6973 --- [0.0-8083-exec-1] o.s.web.servlet.DispatcherServlet        : [] Initializing Servlet 'dispatcherServlet'
2020-05-12 16:03:44.290  INFO 6973 --- [0.0-8083-exec-1] o.s.web.servlet.DispatcherServlet        : [] Completed initialization in 16 ms
	```

   If you see error messages about Redis, make sure all the pods in your Spinnaker instance are `READY`. You can check the IP address and port for each service in `~/.spinnaker/spinnaker-local.yml`.

## Test the plugin

1. Access the the Spinnaker UI (http://your-VM-ip:9000)
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
