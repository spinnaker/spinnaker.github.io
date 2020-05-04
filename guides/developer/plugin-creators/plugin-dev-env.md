---
layout: single
title: "Plugin Test Environment"
sidebar:
  nav: guides
---

This guide explains how to set up a local Spinnaker environment on your MacBook so you can test your plugin. A Spinnaker microservice running inside IntelliJ communicates with the other Spinnaker services running in a local VM.

For example:
* OSX using IP 192.168.64.1 and the VM using 192.168.64.2
* Orca running on http://192.168.64.1:8083
* All other services running on 192.168.64.2

Software and versions used in this guide:

* Java Development Kit, 1.8
* [Multipass](https://multipass.run/), 1.2.1
* [IntelliJ IDEA](https://www.jetbrains.com/idea/), 2020.1
* [Minnaker](https://github.com/armory/minnaker), 0.0.17
* [Spinnaker](https://www.spinnaker.io/community/releases/versions/), 1.2.0
* [Halyard](https://console.cloud.google.com/gcr/images/spinnaker-marketplace/GLOBAL/halyard), 1.35.3
* [Orca](https://github.com/spinnaker/orca/), branch `release-1.20.x`
* [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin), 1.1.5

## Prerequisites

* Your OSX workstation has at least 16GB of RAM and 30GB of available storage
* You have installed JDK 1.8; see [AdoptOpenJDK](https://adoptopenjdk.net/) for how to install multiple versions of the JDK on OSX
* You have installed Multipass
* You have installed and are familiar with IntelliJ

## Install Spinnaker in a Multipass VM

 Minnaker is an open source tool that installs the latest release of Spinnaker and Halyard on [Lightweight Kubernetes (K3s)](https://k3s.io/).

1. Launch a Multipass VM **with 2 cores, 10GB of memory, 30GB of storage**

   ```bash
   multipass launch -c 2 -m 10G -d 30G
   ```

1. Get the name of your VM

   ```bash
   multipass list
   ```

1. Access your VM

   ```bash
   multipass shell <vm-name>
   ```

1. Download and unpack Minnaker

   ```bash
   curl -LO https://github.com/armory/minnaker/releases/latest/download/minnaker.tgz
   tar -xzvf minnaker.tgz
   ```

1. Install Spinnaker

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

   If you need to access the Halyard pod, execute:

   ```bash
   export HAL_POD=$(kubectl -n spinnaker get pod -l app=halyard -oname | cut -d'/' -f 2)
   kubectl -n spinnaker exec -it ${HAL_POD} bash
   ```

   Consult the Minnaker [README](https://github.com/armory/minnaker/blob/master/readme.md#changing-your-spinnaker-configuration) for basic troubleshooting information if you run into issues.

1. Configure Minnaker to listen on all ports:

   ```bash
   ./minnaker/scripts/utils/expose_local.sh
   ```

## Configure Minnaker for a local external service

Decide which Spinnaker services you want to run locally. This example uses Orca.

Configure Minnaker to expect the relevant service to be external:

```bash
./minnaker/scripts/utils/external_service_setup.sh orca
```

`external_service_setup.sh` removes the previous configuration each time you run it. If you want to run multiple services locally, specify them delimited by a space:

```bash
./minnaker/scripts/utils/external_service_setup.sh orca echo
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

Copy the `services` section between the dotted lines.    

## Configure your OSX workstation for the local service

Create or edit the `~/.spinnaker/spinnaker-local.yml` file and paste the previously copied output into it.

## Run a Spinnaker Service in IntelliJ

In this example, you are using the Orca branch that corresponds to the Spinnaker version you installed.

1. Clone the service you need to test your plugin

   ```bash
   git clone --single-branch --branch release-1.20.x https://github.com/spinnaker/orca.git
   ```

1. Open the Orca project in IntelliJ

   * If you don't have a project open, you see a "Welcome to IntellJ IDEA" window.
      1. Click **Open or Import**
      1. Navigate to your directory
      1. Click on `build.gradle` and click **Open**
      1. Select **Open as Project**

   * If you already have one or more projects open, do the following:
      1. Use the menu **File** > **Open**
      1. Navigate to your directory
      1. Click on `build.gradle` and click **Open**
      1. Select **Open as Project**

1. Grab a beverage and snack while you wait for IntelliJ to finish indexing the project

Through the next few steps, if you see an `Unable to find Main` log message or fields are grayed out, reimport the project:

   1. **View** > **Tool Windows** > **Gradle**
   1. In the Gradle window, right click "Orca" and then click **Reimport Gradle Project**

1. Click the **Add Configuration** button to open the **Run/Debug Configurations** window
1. Click the `+` button to create a new configuration
1. Select **Application**
1. Enter "RunOrca" in the **Name** field
1. **Main class**  Click the **...** button.  Either wait for it to load and select "Main (com.netflix.spinnaker.orca) or click on "Project" and navigate to `orca > orca-web > src > main > groovy > com.netflix.spinnaker > orca > Main`

1. In the dropdown for "Use classpath of module", select "orca-web_main"

1. Click "Apply" and then "OK"

1. To build and run the thing, click the little green triangle next to your configuration (top right corner, kinda)

Now magic happens.

## Start doing plugin-ey things

Follow the "debugging" section here: https://github.com/spinnaker-plugin-examples/pf4jStagePlugin

notes:
* Create the `plugins` directory in the git repo (e.g., `~/git/spinnaker/orca/plugins`) and put the `.plugin-ref` in there
* If you don't see the gradle tab, you can get to it with View > Tool Windows > Gradle

## Build and test the randomWait stage

This assumes you have a Github account, and are logged in.

1. You *probably* want to work on a fork.  Go to github.com/spinnaker-plugin-examples/pf4jStagePlugin

1. In the top right corner, click "Fork" and choose your username to create a fork.  For example, mine is `justinrlee` so I end up with github.com/justinrlee/pf4jStagePlugin

1. On your workstation, choose a working directory.  For example, `~/git/justinrlee`

   ```bash
   mkdir -p ~/git/justinrlee
   cd ~/git/justinrlee
   ```

1. Clone the repo

   ```bash
   git clone https://github.com/justinrlee/pf4jStagePlugin.git
   ```

   _or, if you have a Git SSH key set up_

   ```bash
   git clone git@github.com:justinrlee/pf4jStagePlugin.git
   ```

1. Check out a tag.

   If you are using Spinnaker 1.19.x, you probably need a 1.0.x tag (1.0.x is compatible 1.19, 1.1.x is compatible with 1.20)

   List available tags:

   ```bash
   cd pf4jStagePlugin
   git tag -l
   ```

   Check out the tag you want:

   ```bash
   git checkout v1.0.17
   ```

   Create a branch off of it (optional, but good if you're gonna be making changes).  This creates a branch called custom-stage

   ```bash
   git switch -c custom-stage
   ```

1. Build the thing from the CLI

   ```bash
   ./gradlew releaseBundle
   ```

   This will generate an orca .plugin-ref file (`random-wait-orca/build/orca.plugin-ref`).  

1. Copy the `orca.plugin-ref` file to the `plugins` directory in your `orca` repo.

   Create the destination directory - this will depend on where you cloned the orca repo

   ```bash
   mkdir -p ~/git/spinnaker/orca/plugins
   ```

   Copy the file

   ```bash
   cp random-wait-orca/build/orca.plugin-ref ~/git/spinnaker/orca/plugins/
   ```

1. Create the orca-local.yml file in `~/.spinnaker/`

   This tells Spinnaker to enable and use the plugin

   Create this file at `~/.spinnaker/orca-local.yml`:

   ```bash
   # ~/.spinnaker/orca-local.yml
   spinnaker:
     extensibility:
      plugins:
         Armory.RandomWaitPlugin:
          enabled: true
          version: 1.0.17
          extensions:
            armory.randomWaitStage:
              enabled: true
              config:
                defaultMaxWaitTime: 60
   ```

1. In IntelliJ (where you have the Orca project open), Link the plugin project to your current project

   1. Open the Gradle window if it's not already open (View > Tool Windows > Gradle)

   1. In the Gradle window, click the little '+' sign

   1. Navigate to your plugin directory (e.g., `/git/justinrlee/pf4jStagePlugin`), and select `build.gradle` and click Open

1. In the Gradle window, right click "orca" and click "Reimport Gralde Project"

1. In IntelliJ, create a new build configuration

   1. In the top right, next to the little hammer icon, there's a dropdown.  Click "Edit Configurations..."

   1. Click the '+' sign in the top left, and select "Application"

   1. Call it something cool.  Like "Build and Test Plugin"

   1. Select the main class (Either wait for it to load and select "Main (com.netflix.spinnaker.orca) or click on "Project" and navigate to `orca > orca-web > src > main > groovy > com.netflix.spinnaker > orca > Main`)

   1. In the dropdown for "Use classpath of module", select "orca-web_main"

   1. Put this in the "VM Options" field put this: '`-Dpf4j.mode=development`'

   1. In the "Before launch" section of the window, click the '+' sign and add "Build Project"

   1. Select "Build" in the "Before launch" section and click the '-' sign to remove it (you don't need both "Build" and "Build Project")

   1. Click "Apply" and then "OK"

1. Run your stuff.

   1. If the unmodified Orca is still running, click the little stop icon (red square in top right corner)

   1. Select your new build configuration in the dropdown

   1. Click the runicon (little green triangle)

   1. In the console output you should see something that looks like this:

       ```
       2020-04-30 10:17:41.242  INFO 53937 --- [          main] com.netflix.spinnaker.orca.Main         : [] Starting Main on justin-mbp-16.lan with PID 53937 (/Users/justin/dev/spinnaker/orca/orca-web/build/classes/groovy/main started by justin in /Users/justin/dev/spinnaker/orca)
       2020-04-30 10:17:41.245  INFO 53937 --- [          main] com.netflix.spinnaker.orca.Main         : [] The following profiles are active: test,local

       ...

       2020-04-30 10:17:44.276  WARN 53937 --- [          main] c.n.s.config.PluginsAutoConfiguration   : [] No remote repositories defined, will fallback to looking for a 'repositories.json' file next to the application executable
       2020-04-30 10:17:44.410  INFO 53937 --- [          main] org.pf4j.AbstractPluginManager          : [] Plugin 'Armory.RandomWaitPlugin@unspecified' resolved
       2020-04-30 10:17:44.411  INFO 53937 --- [          main] org.pf4j.AbstractPluginManager          : [] Start plugin 'Armory.RandomWaitPlugin@unspecified'
       2020-04-30 10:17:44.413  INFO 53937 --- [          main] i.a.p.s.wait.random.RandomWaitPlugin    : [] RandomWaitPlugin.start()
       ```

   1. If you see "no class Main.main" or something, in the Gradle window, try right click on "orca" and reimport Gradle project and try again.

1. Test your stuff

   1. Go into the Spinnaker UI (should be http://your-VM-ip:9000)

   1. Go to applications > spin > pipelines

   1. Create a new pipeline

   1. Add stage

   1. Edit stage as JSON (bottom right)

   1. Paste this in there:

      ```json
      {
        "maxWaitTime": 15,
        "name": "Test RandomWait",
        "type": "randomWait"
       }
      ```

   1. Update stage

   1. Save changes

   1. Click back to pipelines (pipelines tab at top)

Magic.  Maybe.  Maybe not.
