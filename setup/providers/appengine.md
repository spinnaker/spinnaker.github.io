---
layout: single
title:  "App Engine"
sidebar:
  nav: setup
---

{% include toc %}

For App Engine, an [__Account__](/setup/providers/overview#accounts) maps to an App Engine application.

## Prerequisites

Sign into the [Google Cloud Console](https://console.cloud.google.com) and create a project if you don't already have one.
Use your project name in place of `my-spinnaker-project` below.

1. Enable APIs in your <code>my-spinnaker-project</code> project.
    * Go to the API Management page.
    * Enable the **App Engine Admin** and **Compute Engine APIs**.

2. If this is your first time deploying to App Engine in your project, create an App Engine application using 
   `gcloud`. You cannot change your application's region, so pick wisely:

   ```bash
   gcloud app create --region <e.g., us-central>
   ```
3. Spinnaker does not need to be given service account credentials if it is running on a Google Compute Engine VM _and_
   it is deploying to an App Engine application inside the same Google Cloud Platform project in which it is running. If Spinnaker
   will need service account credentials, follow these steps for the project you would like to deploy to:
    * Inside the [Google Cloud Console](https://console.cloud.google.com), go to the Credentials tab
     on the API Management page.
    * Select the **Service account key** item from the **Create credentials** menu.
    * Select a service account, the **JSON** key type, and click **Create**.
    * Safeguard the JSON file that your browser will download.

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider appengine enable
```

Next, run the following `hal` command to add an account named `my-appengine-account` to your list of App Engine accounts:

```bash
hal config provider appengine account add my-appengine-account \ 
  --project <my-spinnaker-project> \
  --json-path <path-to-service-account-key>
```

You can omit the `--json-path` flag if Spinnaker does not need service account credentials.

## Advanced Account Settings

Spinnaker deploys to App Engine by cloning your application source code from a git repository. Unless your code 
is public, Spinnaker needs a mechanism to authenticate with your repositories - many of the configuration flags for 
App Engine manage this authentication. 

You can view the available configuration flags for App Engine within the 
[Halyard reference](https://github.com/spinnaker/halyard/blob/master/docs/commands.md#hal-config-provider-appengine-account-add).


