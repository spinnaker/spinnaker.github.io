---
layout: single
title:  "Pipeline Stages"
sidebar:
  nav: reference
---

{% include toc %}

This article describes the currently-supported stages that you can add to your
Spinnaker pipelines.

Note that when you're creating a pipeline, you probably won't see every stage
that's listed here: you'll only see the stages that Spinnaker supports on your
provider.

## General

### Bake
Bake an image from the specified packages. Baking here refers to the process
of creating a machine image. Spinnaker's bakery is backed by
[Hashicorp's Packer](https://www.packer.io/intro/). Spinnaker provides default
[Packer templates](https://www.packer.io/docs/templates/index.html) and base
machine images in order to get you started, but see the
[bakery configuration guide](/setup/bakery/) if you want to customize your bake
process.

Note that Spinnaker skips the bake process if it detects that a new bake is
unnecessary. Spinnaker generates a unique key for each bake based on the bake
stage parameters: base OS, versioned packages, etc. If either the packages or
the bake stage parameters have changed, Spinnaker triggers a new bake. To change
the default behavior and re-bake your image each time the pipeline runs, select
**Rebake** in the **Bake Configuration** section.

### Canary Analysis
Use [Kayenta](/reference/architecture/#spinnaker-microservices) to run
[automated canary analysis](/guides/user/canary/) against the deployment
before fully deploying. Note that this stage _only_ handles analysis; you're
responsible for provisioning and cleaning up your canary instances. This is
typically done within the same pipeline via stages surrounding the
Canary Analysis stage.

For a step-by-step explanation of how to set up a Canary Analysis stage see the
[how-to guide](/guides/user/canary/stage/).

### Check Preconditions
Check for preconditions before continuing. For example, you can check that
your cluster is a particular size, or add a pipeline expression. See the
[pipeline expressions guide](/guides/user/pipeline-expressions/) for more
information about creating and using pipeline expressions.

### Clone Server Group
Copies all attributes of the original Server Group into a new Server Group (the
image that was deployed to it, its capacity, etc). You can choose to override
any of the properties of the original Server Group when creating the new one.

### Deploy
Deploy the previously baked or found image using the specified deployment
strategy. Spinnaker provides built-in support for both red/black (also known as
blue/green) and Highlander deployment strategies. You can also choose to deploy
with no impact on existing Server Groups, or build your own custom deployment
strategy.

### Destroy Server Group
Delete a Server Group and its resources from the specified Cluster. You must
specify whether you want to delete the newest, oldest, or previous
(second-most-recently deployed) Server Group when this stage starts.

### Disable Cluster
Disable the specified Cluster, which means that the cluster remains up but
stops handling traffic. If desired, you can leave a specific number of Server
Groups running while the rest of the cluster is disabled.

### Disable Server Group
The specified Server Group remains up but stops handling any traffic.
Any auto-scaling policies related to this Server Group will also be disabled.
Disabling Server Groups makes it easy to both route traffic to a new Server
Group and roll back those changes if necessary. You must choose whether to
disable the Server Group which is newest, oldest, or previous
(second-most-recently deployed) when this stage starts.

### Enable Server Group
Tell Spinnaker to resume sending traffic to the Server Group. The configuration
of your Load Balancer determines how traffic is routed among newly-enabled
Server Groups and any existing Server Groups. Enabling a Server Group also
re-enables auto-scaling policies, if applicable.

### Find Artifact From Execution
Find and bind an artifact from a different pipeline execution to the current
one, including artifacts from different Spinnaker applications. To do this,
specify the type of artifact (GCS, GitLab, Docker, etc) and its name. You can
specify that Spinnaker should only consider executions that meet certain
criteria, such as ones that have completed successfully or that are currently
running. Spinnaker will always return the artifact from the most recent
execution that matches your criteria.

### Find Image From Cluster
Find an image to deploy from an existing Cluster. Make sure that you specify the
Cluster and Server Group such that there is exactly one match, or this may
behave in unexpected ways.

### Find Image From Tags
Find the newest image that matches all specified tags. The image tag can come
from any source. Regardless of whether you tagged your image through the
Spinnaker [Tag Image](#tag-image) stage or through a process outside of
Spinnaker, the **Find Image From Tags** stage can find it as long as Spinnaker
has previously interacted with the image.

In Spinnaker, tags can only contain lowercase letters, numeric characters,
underscores and dashes. Depending on your provider, you may need to specify what
region to search for the image.

### Google Cloud Build

Run a Google Cloud Build build by specifing a build config as either an artifact or
as inline YAML. Artifacts produced by the build can be injected into the pipeline
and used by downstream stages. You must [configure Google Cloud Build](/setup/ci/gcb/)
in order to use this stage.

### Jenkins
Run the specified job in Jenkins. You must [set up Jenkins](/setup/ci/jenkins/)
in order to use this stage. Once Jenkins is configured, your Jenkins master and
available jobs are automatically populated in the respective drop-down menus.

### Manual Judgment
Wait for the user to click **Continue** before continuing. You can specify
instructions for how to decide whether to continue, or add input options
that users can choose from. These input options can be used to determine
pipeline behavior in downstream stages. For example, you can use the [**Check
Preconditions**](#check-preconditions) stage to ensure that a given stage only
runs if a particular input is specified.

Note: The Manual Judgement stage requires that Spinnaker's Echo service is
enabled in order to work.

### Pipeline
Select any pipeline and run it as a sub-pipeline. You can run pipelines from
both the current application and any other Spinnaker applications that you have
access to. You can choose whether to wait for the results of the sub-pipeline
before this stage completes. If you wait for results, the end state of this
stage reflects the end state of the sub-pipeline. Otherwise, the this stage is
marked successful as soon as the sub-pipeline starts.

### Resize Server Group
Resize the oldest, newest, or second newest Server Group. You can resize the
Server Group by either a percentage of its current size or a specific amount.
The available resizing strategies are:
* **Scale Up**, which increases the size of the target Server Group.
* **Scale Down**, which decreases the size of the target Server Group.
* **Scale to Cluster Size**, which increases the size of the target Server Group
to match the largest Server Group in the Cluster. Optionally, you can specify
additional capacity to add as well.
* **Scale to Exact Size**, which adjusts the size of the target Server Group to
match the specified capacity.

### Rollback Cluster
Roll back one or more regions in a Cluster.

### Run Job
Run a container. You need to
[set up a docker registry](/setup/install/providers/docker-registry/) so that
Spinnaker can access the images to run. Once you're set up correctly, placing
your cursor in the the **Image** field displays a drop-down menu of available
images.

### Scale Down Cluster
Scale down a cluster. You can prevent this stage from scaling down active Server
Groups, or choose to keep a certain number of Server Groups at their current
size while the rest are scaled down.

### Script
Execute an arbitrary script as part of your pipeline. Spinnaker uses Jenkins to
sandbox your scripts, so you need to [set up Jenkins](/setup/ci/jenkins/) in
order to use it. If you already have Jenkins set up, make sure that you have
[configured it to run scripts](/setup/features/script-stage/).

The only required field in this stage is **Command**, where you must specify the
command to run the script. Otherwise, you can use any of the fields that are
relevant to your use case in order to describe the script location and specifics
about its output, environment, and so on.

### Shrink Cluster
Shrink a given cluster to contain nothing except a specified number of either
the newest or the largest Server Groups. You can choose whether to delete active
Server Groups if they don’t fit the specified criteria.

### Tag Image
Tag the current image in your pipeline with all specified tags. Tags can only
contain lowercase letters, numeric characters, underscores and dashes. Spinnaker
converts the tags to your provider's equivalent: for example, it creates labels
for GCE images, whereas it creates tags for AWS images, and so on.

### Wait
Wait a specified period of time before proceeding. You can choose to manually
skip some or all of the wait period during execution.

### Webhook
Make an API call to an external system as part of your pipeline.

Supply the URL to send the request to and the desired HTTP method, as well as
optionally any desired custom headers and a JSON payload to add to the request.
At this point, this stage is marked successful as if it receives a 2XX or 3XX
response, fails on a 4XX, or retries on 5XX. The webhook URL, payload, status
endpoint, and final status are all shown under the pipeline execution details in
the Spinnaker UI.

Note that you can use [pipeline expressions](/reference/pipeline/expressions/)
in both the URL field and the payload. When the stage completes, the `webhook`
field of the stage context contains the payload, which allows you to use it in
future pipeline expressions. For example, you can reference the final status
code with the expression `${#stage("My Webhook
Stage")["context"]["webhook"]["statusCode"]}`.

If you need more details to determine the success of your request, check the
**Wait for completion** checkbox. Spinnaker then polls a status URL to determine
the progress of the stage. You can supply the status URL to Spinnaker in one of
the following ways:

*   **GET method against webhook URL**: Spinnaker polls the webhook URL using
    GET to determine the status.
*   **From the Location header**: Spinnaker parses the Location header of the
    webhook's response call to find the status URL, and polls that URL.
*   **From webhook's response**: Spinnaker parses the response from the original
    request, and polls the returned URL.

In all cases, you then need to provide details about how to access and interpret
the status:

*   **Status JsonPath** is a required field which you use to specify the path to
    the status information in the response JSON of the status URL, such as
    `buildInfo.status`.
*   **SUCCESS, CANCELED, and TERMINAL status mappings** are comma-separated
    lists of strings that represent successful, canceled, or terminal (failed)
    statuses, respectively. These are required fields: Spinnaker continues
    polling until it sees one of the specified statuses in the status URL's
    response.
*   **Progress location** is optional, and lets you specify the path to detailed
    progress information in the status URL's response JSON, such as
    `buildInfo.progress`. It shows up in the **Info** field of the pipeline
    execution details.

If you find yourself recreating the same webhook stage repeatedly, you can
create a [custom webhook](/guides/operator/custom-webhook-stages/) stage. A
custom webhook stage is a webhook stage specifically named and configured for
your application's needs, which shows up in the standard pipeline stages
dropdown menu.

You can [add more certification authorities](/guides/operator/webhook-custom-trust-store/)
to trust when making webhook calls over HTTPS.

### Wercker
Run the specified Wercker pipeline. You must [set up Wercker](/setup/ci/wercker/)
in order to use this stage. Once Wercker has been configured, your Wercker
masters and the applications and pipelines available for your master's
credentials will be shown in the drop-down menus. When a Wercker pipeline stage
runs, a link to the Wercker run will be available, and the status of
the Wercker run will be reported in Spinnaker.

## App Engine

### Start a Server Group
Spin up instances for the Server Group according to its scaling settings. This
is distinct from [Enable Server Group](#enable-server-group) because it entails
starting new instances, rather than sending traffic to existing instances. You
can choose whether to start the newest, oldest, or previous
(second-most-recently deployed) Server Group.

Note that you can only use this stage if you're using an App Engine flexible
environment or are using manual scaling. Both options can be configured in your
`app.yaml`.

### Stop a Server Group

Scale the specified Server Group down to zero instances. This is distinct from
[Disable Server Group](#disable-server-group), where the specified server group
remains up but stops handling traffic. You can choose whether to stop the
newest, oldest, or previous (second-most-recently deployed) Server Group.

Note that you can only use this stage if you're using an App Engine flexible
environment or are using manual scaling. Both options can be configured in your
`app.yaml`.

### Edit Load Balancer
Set how much traffic a given version of your app can receive. You can specify
versions by name — for example, `sample-cluster-v000` — or choose to send
traffic to the newest, oldest, or previous (second-most-recently deployed)
Server Group. For an example of how to do this, see the
[App Engine Source to Prod codelab](/guides/tutorials/codelabs/appengine-source-to-prod/#edit-load-balancer-stage).

Note that a Spinnaker Load Balancer maps to an App Engine service, as specified
in a version's `app.yaml`. Your version will be deployed to the `default`
service if one was not specified.

## AWS

### Modify AWS Scaling Process
Suspend/resume scaling processes.

## Cloud Foundry

### Create Service Key
Generate credentials for a service instance. Similar to `cf create-service-key`; see the Cloud Foundry documentation about how to [Create a Service Key](https://docs.cloudfoundry.org/devguide/services/service-keys.html#create).

### Delete Service Key
Delete an existing service key. Similar to `cf delete-service-key`; see the Cloud Foundry documentation about how to [Delete a Service Key](https://docs.cloudfoundry.org/devguide/services/service-keys.html#delete).

### Deploy Service
Create a service instance. Similar to `cf create-service`; see the Cloud Foundry documentation about [Creating Service Instances](https://docs.cloudfoundry.org/devguide/services/managing-services.html#create).

### Destroy Service
Delete a service instance. Similar to `cf delete-service`; see the Cloud Foundry documentation about how to [Delete a Service Instance](https://docs.cloudfoundry.org/devguide/services/managing-services.html#delete).

### Map Load Balancer
Map a Load Balancer (a Cloud Foundry route) to a server group (Cloud Foundry app).
The domain must already exist in the Cloud Foundry org.
If the route does not already exist, it will be created.
Similar to `cf map-route`; see the Cloud Foundry documentation about how to [Map a Route to Your App](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html#map-route).

### Share Service
Share a service instance with a specific org / spaces.
Similar to `cf share-service`; see the Cloud Foundry documentation about [Sharing a Service Instance](https://docs.cloudfoundry.org/devguide/services/sharing-instances.html#sharing).

### Unmap Load Balancer
Unmap a Load Balancer (a Cloud Foundry route) from a server group (Cloud Foundry app).
Similar to `cf unmap-route`; see the Cloud Foundry documentation about how to [Unmap a Route](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html#unmap-route).

### Unshare Service
Unshare a service instance with a specific org / space.
Similar to `cf unshare-service`; see the Cloud Foundry documentation about [Unsharing a Service Instance](https://docs.cloudfoundry.org/devguide/services/sharing-instances.html#unsharing).

## Kubernetes

### Bake (Manifest)
Bake a manifest (or multi-doc manifest set) using a template renderer such as
Helm.

### Delete (Manifest)
Destroy a Kubernetes object created from a manifest. If multiple label selectors
are specified, they are combined with the logical _AND_ operator. See [the
Kubernetes reference
page](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors)
for more details.

### Deploy (Manifest)
Deploy a Kubernetes manifest YAML/JSON file.

### Find Artifacts From Resource
Find artifacts from a Kubernetes resource.

### Patch (Manifest)
Update an already existing Kubernetes resource in place using the [Kubernetes
patch operation](https://kubernetes.io/docs/tasks/run-application/update-api-object-kubectl-patch/).
Spinnaker can update the resource without knowing the entire resource (that is,
you have to specify only the portion of the manifest you want to update).

The patch stage can be used to add a label or update a sidecar container image
for a set of resources. It can also be used to implement a [rainbow deployment
](http://brandon.dimcheff.com/2018/02/rainbow-deploys-with-kubernetes/)
strategy for Kubernetes by first deploying a new ReplicaSet and then patching
the fronting service's selectors to point to the new ReplicaSet.

When patching with a _strategic_ or _merge_ strategy, Spinnaker also supports [artifact substitution
](/reference/artifacts/in-kubernetes-v2/#binding-artifacts-in-manifests) for the
patch content just like the resource manifest in the deploy stage.

### Scale (Manifest)
Scale a Kubernetes object created from a manifest.

### Undo Rollout (Manifest)
Rollback a manifest a target number of revisions.


## Custom Stages


### Custom Webhook

Extend Spinnaker with [predefined Webhook stages](/guides/operator/custom-webhook-stages/).

### Custom Job

Extend Spinnaker with [predefined Run Job stages](/guides/operator/custom-job-stages/).
