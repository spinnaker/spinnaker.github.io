---
layout: single
title:  "Kubernetes Source To Prod"
sidebar:
  nav: guides
redirect_from: /guides/tutorials/codelabs/kubernetes-source-to-prod/
---

{% include toc %}

In this codelab you will configure:

* A GitHub repo containing both your code to be deployed, and the Kubernetes
  manifests that will run your code.

* A set of Spinnaker pipelines to deploy changes to your code, manifests, and
  application configuration from source to production.

# 0: Prerequisites

Before we begin, we need to do the following:

* [Configure GitHub](#configure-github)

  You need some source code and manifests to deploy stored in GitHub. We have a
  repository you can fork to follow along easily.

* [Configure DockerHub](#configure-dockerhub)

  The source code in GitHub will be configured to build automatically on tag
  pushes.

* [Configure Kubernetes](#configure-kubernetes)

  Two Kubernetes clusters, one for staging and one for prod.

* [Configure Spinnaker](#configure-spinnaker)
  
  A running Spinnaker instance, able to deploy to Kubernetes and download
  artifacts from GitHub.

* [Configure Webhooks](#configure-webhooks)

  GitHub & DockerHub webhooks pointing at Spinnaker, alerting when commits and
  docker images are pushed respectively.

## Configure GitHub

The code we'll be deploying is stored
[here](https://github.com/lwander/spin-kub-v2-demo). Feel free to fork this
into your own account, and make changes/deploy from there.

> __☞ Note__: The manifests in this repository point to a [specific docker
> image](https://github.com/lwander/spin-kub-v2-demo/blob/master/manifests/demo.yml#L30-L37).
> If you want to trigger off of changes made to your own docker image, change
> the image name to reflect that.

## Configure DockerHub

If you're completely unfamiliar with Docker, start
[here](https://docs.docker.com/engine/getstarted/).

[This guide](https://docs.docker.com/docker-hub/builds/) covers how to get your
GitHub repository (from above) to trigger Docker builds in DockerHub. We'll be
relying on this to automatically push code changes into your staging
environment.  In the end your repository should look something like
[this](https://hub.docker.com/r/lwander/spin-kub-v2-demo/).

> __☞ Note__: Before continuing, run the created trigger at least once to both
> push a `:latest` image, as well as validate that your configuration is
> working. This can be done by pushing a commit to your GitHub repo to trigger
> a Docker build.

## Configure Kubernetes

Create two clusters following one of the guides
[here](http://kubernetes.io/docs/getting-started-guides/). Once you are
finished, make sure that you have an up-to-date <code>~/.kube/config</code>
file that has entries for both clusters you want to deploy to. Details on
kubeconfig files [here](http://kubernetes.io/docs/user-guide/kubeconfig-file/).

## Configure Spinnaker

We will be deploying Spinnaker to one of your Kubernetes clusters. To do so,
start by [installing halyard](/setup/install/halyard).

### Choose a storage service

Pick a storage service [here](/setup/install/storage), and run the required
`hal` commands.

### Add your Kubernetes accounts

You will need to configure two Kubernetes accounts. See the Kubernetes
contexts created in the prior step using:

```bash
kubectl config get-contexts
```

The output should look like (although the names may vary):

```
CURRENT   NAME                       CLUSTER        AUTHINFO       NAMESPACE
*         staging-demo-us-central1   staging-demo   staging-demo
          prod-demo-us-central1      prod-demo      prod-demo
```

Record the names of the contexts as `$STAGING_CONTEXT` and `$PROD_CONTEXT`.

Now we will register both contexts with Spinnaker.

```bash
hal config provider kubernetes account add prod-demo \
  --context $PROD_CONTEXT

hal config provider kubernetes account add staging-demo \
  --context $STAGING_CONTEXT
```

### Configure GitHub artifact credentials

Make sure to [add GitHub as an artifact account](/setup/artifacts/github). This
will allow us to fetch the manifests later.

### Deploy Spinnaker

Pick a version & specify that you want to deploy Spinnaker inside the staging
cluster:

```bash
hal config version edit --version $(hal version latest -q)

hal config deploy edit --type distributed --account-name staging-demo
```

And finally, deploy Spinnaker.

```bash
hal deploy apply
```

## Configure webhooks

Now that Spinnaker is running, you need to point both Docker and GitHub
webhooks at Spinnaker to send events when Docker images and manifest changes
happen respectively.

### Give Spinnaker an external endpoint

> :warning: __This is for the codelab only! Do not do this in production__.
> We're giving an unsecured Spinnaker an external endpoint to easily do this
> codelab, and are taking limited measures to ensure only GitHub and Docker can
> trigger pipelines. __Tear down Spinnaker once you're done with this
> codelab, or remove any firewall changes to your Kubernetes cluster__.

First, edit the [Gate](/reference/architecture) service to bind a node port.
This means every node in your Kubernetes cluster will forward traffic from that
node port to your Spinnaker gate service. __Your nodes should not be accepting
requests from external IPs__ by default, so making this change doesn't
immediately open Spinnaker to public access.

To do this, first run (this will open the service manifest in your text
editor):

```bash
kubectl edit svc spin-gate -n spinnaker --context $STAGING_CONTEXT
```

and then change the field

```yaml
type: ClusterIP
```

to

```yaml
type: NodePort
```

Next, get the port that `spin-gate` has bound to. You can check this with

```bash
kubectl get svc spin-gate -n spinnaker --context $STAGING_CONTEXT
```

In my case, I see the port is `31355`, which I record into `$NODE_PORT` (`8084`
is the port gate is listening on inside the cluster):

```
NAME        TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
spin-gate   NodePort   10.7.255.85   <none>        8084:31355/TCP   32m
```

Now pick any node in the cluster and record its IP as `$NODE_IP`; for the purposes of
this codelab, we'll be sending external webhooks to `$NODE_PORT` on that node. In
order for these webhooks to work, for this codelab only, open your firewall
on that node to all addresses for TCP connections on `$NODE_PORT`. If you
were running Spinnaker in production with [authentication](/setup/security),
only webhooks would be allowed, which you can reject by header or payload.
See [the webhook guide for more details](/guides/user/triggers/webhooks).

### Allow Docker to post build events

These will be used to trigger pipelines based on new Docker images being
published. Follow the steps shown
[here](https://docs.docker.com/docker-hub/webhooks/) for your repository. The
endpoint you configure must be
`http://${NODE_IP}:${NODE_PORT}/webhooks/webhook/dockerhub`.

### Allow GitHub to post push events

Follow the steps shown
[here](/setup/triggers/github/#configuring-your-github-webhook), where
`ENDPOINT=http://${NODE_IP}:${NODE_PORT}`. Keep track of what you pick as the
`$SECRET`!

# 1: Create a Spinnaker application

When you first open Spinnaker (if you've followed the above
[prerequisites](#0-prerequisites)) it'll be running on `localhost:9000`) you'll
be greeted with the following __Applications__ screen.

{% include figure
   image_path="./app-screen.png"
   caption="By default, Spinnaker indexes your entire cluster, which explains
   why the screen is prepopulated with unrelated infrastructure. This can be
   changed by ommiting namespaces as shown
   [here](/reference/halyard/commands/#hal-config-provider-kubernetes-account-edit)."
%}

Select __Actions__ > __Create Application__, and fill out the form as shown
(the owner email will of course be different):

{% include figure
   image_path="./create-app.png"
%}

After hitting __Create__, you should be brought to an empty __Clusters__ tab:

{% include figure
   image_path="./empty-clusters.png"
%}

# 2: Create a "Deploy to Staging" pipeline

Let's deploy the manifests and code in our staging cluster by setting up
automated pipelines to do so. Start by navigating to __Pipelines__ >
__Configure a new Pipeline__. Name the pipeline as shown and hit create:

{% include figure
   image_path="./staging-pipeline-new.png"
%}

At this point we want to add the manifest from GitHub as an expected artifact
in this pipeline, meaning we expect each time that this pipeline executes,
either a GitHub event will supply us with a new manifest to deploy, or we will
use some default or prior manifest.

Select __Add Artifact__:

{% include figure
   image_path="./add-github-artifact.png"
%}

Select GitHub as the artifact type, and set the __File Path__ to
`manifests/demo.yml`, and select __Use Prior Execution__, to tell
Spinnaker that if no matching artifact is found, to use the last execution's
value. (This will be useful later).

{% include figure
   image_path="./configure-github-artifact.png"
%}

Next, let's add a GitHub trigger:

{% include figure
   image_path="./add-github-trigger.png"
%}

Supply the following configuration values:

| Field | Value |
|-------|-------|
| __Type__ | "Git" |
| __Repo Type__ | "GitHub" |
| __Organization or User__  | The user you forked the above code into. |
| __Project__ | "spin-kub-v2-demo" |
| __Secret__ | The `$SECRET` chosen [above](#allow-github-to-post-push-events). |
| __Expected Artifacts__ | Must reference the `manifests/demo.yml` artifact. |

{% include figure
   image_path="./configure-github-trigger.png"
   caption="We supply the expected artifact to be sure that we only trigger the
   pipeline when that file changes."
%}

With the trigger configuration in place, let's configure a "Deploy manifest"
stage.

First add a stage:

{% include figure
   image_path="./first-stage.png"
%}

Then select the "Deploy (Manifest)" stage type:

{% include figure
   image_path="./add-deploy-manifest-stage.png"
%}

Finally, configure the stage with the following values:

| Field | Value |
|-------|-------|
| __Account__ | "staging-demo" |
| __Cluster__ | "demo" |
| __Manifest Source__ | "Artifact" |
| __Expected Artifact__ | Must reference the `manifests/demo.yml` artifact. |
| __Artifact Account__ | The GitHub artifact account configured above. |

{% include figure
   image_path="./configure-deploy-manifest-stage.png"
%}

Save the pipeline.

# 3. Deploy manifests to staging

Trigger the pipeline by pushing a commit to the `manifests/demo.yml` file in
your repository. The pipeline should start in a few seconds. When it completes,
click __Details__ to see information about the execution:

{% include figure
   image_path="./staging-execution.png"
%}

There are a couple of things to notice here: 

* In the top left we get details about the commit that triggered this
  pipeline. 

* In the __Deploy Status__ we can see what the YAML was that Spinnaker
  deployed. 

* We see that the ConfigMap that we deployed was assigned version
  `-v000`. This was done to ensure that you can statically reference this
  ConfigMap, insulating any Pod that references it from accidental changes.

Next, let's see what this infrastructure looks like in Spinnaker. Navigate to
the __Clusters__ tab, and select the blue Deployment object attached to the
Replica Set shown below:

{% include figure
   image_path="./staging-v001.png"
%}

We can see in the __Artifact__ section on the right that we have bound our
Docker image as well as our ConfigMap.

Let's see what our application is serving. Run:

```bash
kubectl proxy --context $STAGING_CONTEXT
```

And then visit [the sample
service](http://localhost:8001/api/v1/proxy/namespaces/default/services/spinnaker-demo:80/)
in your browser. Let's make a change to this service, and configure Spinnaker
to listen to Docker builds.

# 4. Configure Docker triggers

__Important__: We need to configure DockerHub to build on __Tag__ events only,
if we build on every commit, this particular setup will trigger both when
manifests & code are changed at once. This can be configured under your
Docker repository's __Build Settings__ tab as shown here:

{% include figure
   image_path="./docker-tag-only.png"
   caption="This build rule will create a matching image tag each time you push
   a git tag."
%}

Next, in Spinnaker, let's edit our Pipeline to allow Docker images to trigger a
deployment:

First, add a Docker expected artifact next to our Git expected artifact:

{% include figure
   image_path="./configure-docker-artifact.png"
%}

Next, add a _Webhook_ trigger to listen to build events from DockerHub. The
_Docker_ trigger alone won't provide us with provenance information.

{% include figure
   image_path="./configure-docker-webhook.png"
%}

Finally, back in the "Deploy (Manifest)" stage configuration, select the
Docker artifact to bind in this deployment:

{% include figure
   image_path="./bind-docker.png"
%}

Save the pipeline.

# 5. Deploy Docker to staging

You can push a tag to your repository by running:

```bash
git tag release-1.0
git push origin release-1.0
```

{% include figure
   image_path="./staging-webhook-execution.png"
%}

Notice that this time the trigger was a Webhook trigger, and we see details
about both types of artifacts that we deployed. Since the GitHub file artifact
was configured to __Use Prior Execution__, we redeployed the same manifests as
last time, but with a new Docker image. Because of this, we did not deploy a
new ConfigMap, and kept the version at `-v000`.

> This deployment is a lot faster than the last one, since the docker image was
> already pulled into our cluster, meaning it took less time for the images to
> start running and appear as "Healthy".

Back on the __Clusters__ tab we can see the deployment has rolled out our new
image:

{% include figure
   image_path="./staging-v002.png"
%}

# 6. Configure a validation pipeline

For the sake of a simple codelab, we will control which deployments make it to
production by adding a "Manual Judgement" pipeline. In practice, this can be
replaced by a canary, integration test suite, or other mechanism for validating
staging; however, keeping the manual judgement stage is fine too.

Start by creating a new pipeline, and call it "Validate Staging":

{% include figure
   image_path="./validate-staging-create.png"
%}

We only want this pipeline to run when we successfully deploy to our staging
environment, so create a Pipeline trigger in this new pipeline like shown:

{% include figure
   image_path="./staging-trigger.png"
%}

Add a single stage with type "Manual judgement":

{% include figure
   image_path="./add-manual-judgement.png"
%}

If desired, you can add additional "Instructions" for how to validate the
cluster:

{% include figure
   image_path="./configure-manual-judgement.png"
%}

Save the Pipeline.

# 7. Promote to production

Let's promote these artifacts into our production cluster. Create a new
pipeline, but instead of creating it from scratch, let's copy the "Deploy to
Staging" pipeline like this:

{% include figure
   image_path="./create-promote-copy.png"
%}

We need to make two changes to this pipeline:

First, delete the webhook and Git triggers, and replace it with a pipeline
trigger that depends on the "Validate Staging" pipeline:

{% include figure
   image_path="./validate-staging-trigger.png"
%}

Next, change the __Account__ the "Deploy (Manifest)" stage deploys to
point at __prod-demo__:

{% include figure
   image_path="./deploy-to-prod-account.png"
%}

# 8. Run the full flow

Now our full flow is ready to go - let's kick it off by changing the background
color of our application.

Open `content/index.html` in your text editor, and change the background color
attribute, and generate a new commit. We can safely push this commit to GitHub 
without running our pipeline because we are only listening to change to the
`manifests/demo.yml` file in our "Deploy to Staging" trigger. Tag and push this
commit to generate a new docker build:

```bash
git tag release-1.1
git push origin release-1.1
```

When Spinnaker prompts you, accept (or reject) the manual judgement:

{% include figure
   image_path="./continue.png"
%}

Keep in mind, if you reject the manual judgement, but later change your mind,
you can always trigger this pipeline again using the same context by selecting
__Start manual execution__, and picking the latest parent execution:

{% include figure
   image_path="./prior-execution.png"
%}

Once all three pipelines complete, you should have your docker image running in
both environments:

{% include figure
   image_path="./both-accounts.png"
%}

# 9. Extra credit

At this point there are few things you can play with:

* Change the ConfigMap definition in the manifest file. In particular,
  flip the single flag from "false" to "true". See what happens to the
  ConfigMap version.

* Roll back a "broken" change either in prod or staging using the "Undo
  Rollout" stage.

* Insert [pipeline expressions](/guides/user/pipeline-expressions) into
  your manifest files.

# 10. Teardown

As referenced above, please teardown Spinnaker once you are done:

```bash
hal deploy clean
```
