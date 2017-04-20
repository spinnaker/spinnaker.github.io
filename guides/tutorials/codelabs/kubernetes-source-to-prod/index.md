---
layout: single
title:  "Kubernetes Source To Prod"
sidebar:
  nav: guides
---

{% include toc %}

In this codelab you will be creating a set of basic pipelines for deploying code from a Github repo to a Kubernetes cluster in the form of a Docker container.

Given that there are a number of fully-featured docker registries that both store and build images, Spinnaker doesn't build Docker images but instead depends on any registry that does.

The workflow generally looks like this:
  1. Push a new tag to your registry. (Existing tag changes are ignored for the sake of traceability - see below).
  2. Spinnaker sees the tag and deploys the new tag in a fresh Replica Set, and optionally deletes or disables any old Replica Sets running this image.
  3. The deployment is verified externally.
  4. Spinnaker now redeploys this image into a new environment (production), and disables the old version the Replica Set was managing

> **Existing tags are ignored for the sake of traceability.** 
>
> The rational is that repeatedly deploying the same tag (<code>:latest</code>, <code>:v2-stable</code>, etc...) reduces visibility into what version of your application is actually serving traffic. This is particularly true when you are deploying new versions several times a day, and different environments (staging, prod, test, dev, etc...) will each have different versions changing at different cadences.
> 
> Of course, there is nothing wrong with updating a stable tag after pushing a new tag to your registry to maintain a vetted docker image. There are also ways to ensure only a subset of docker tags for a particular image can trigger pipelines, but that'll be discussed in a future codelab.

# 0. Setup

We need a few things to get this working. 

  1. [A Github repo containing the code we want to deploy](http://www.spinnaker.io/v1.0/docs/kubernetes-source-to-prod#section-configuring-github).
  2. [A Dockerhub repo configured to build on changes to the above repo](http://www.spinnaker.io/v1.0/docs/kubernetes-source-to-prod#section-configuring-dockerhub).
  3. [A running Kubernetes cluster](http://www.spinnaker.io/v1.0/docs/kubernetes-source-to-prod#section-configuring-kubernetes).
  4. [A running Spinnaker deployment configured with the contents of steps 2 and 3](http://www.spinnaker.io/v1.0/docs/kubernetes-source-to-prod#section-configuring-kubernetes).

## Configuring Github

The code I'll be deploying is stored [here](https://github.com/lwander/spin-kub-demo). Feel free to fork this into your own account, and make changes/deploy from there. What's needed is a working <code>Dockerfile</code> at the root of the repository that can be used to build some artifact that you want to deploy. If you're completely unfamiliar with Docker, I recommend starting [here](https://docs.docker.com/engine/getstarted/).

## Configuring Dockerhub

Create a new [repository on Dockerhub](https://hub.docker.com/). [This guide](https://docs.docker.com/docker-hub/builds/) covers how to get your Github repository hooked up to your new Dockerhub repository by creating an automated build that will take code changes and build Docker images for you. In the end your repository should look something like [this](https://hub.docker.com/r/lwander/spin-kub-demo/).

> **Make sure Github is configured to send events to Dockerhub.**
>
> This can be set under your Github repositories Settings > Webhooks & Services > Services > Docker.

## Configuring Kubernetes

Follow one of the guides [here](http://kubernetes.io/docs/getting-started-guides/). Once you are finished, make sure that you have an up-to-date <code>~/.kube/config</code> file that points to whatever cluster you want to deploy to. Details on kubeconfig files [here](http://kubernetes.io/docs/user-guide/kubeconfig-file/).

## Configuring Spinnaker

We will be deploying Spinnaker to the same Kubernetes cluster it will be managing. To do so, follow the steps in [this guide](https://github.com/spinnaker/spinnaker/tree/master/experimental/kubernetes/simple), being sure to use [this section](https://github.com/spinnaker/spinnaker/tree/master/experimental/kubernetes/simple/#anything-else-except-for-ecr) to configure your registry.

# 1. Create a Spinnaker Application

Spinnaker applications are groups of resources managed by the underlying cloud provider, and are delineated by the naming convention `<app name>-`. Since Spinnaker and a few other Kubernetes-essential pods are already running in your cluster, your _Applications_ tab will look something like this:

![Applications data and spin were created by Spinnaker, the rest were created by Kubernetes.](applications.png)

Under the _Actions_ dropdown select _Create Application_ and fill out the following dialog:

![If you've followed the Source to Prod tutorial for the VM based providers, you'll remember that you needed to select "Consider only cloud provider health when executing tasks". Since Kubernetes is the sole health provider by definition, selecting this here is redundant, and unnecessary.](appfill.png)

You'll notice that you were dropped in this _Clusters_ tab for your newly created application. In Spinnaker's terminology a _Cluster_ is a collection of _Server Groups_ all running different versions of the same artifact (Docker Image). Furthermore, _Server Groups_ are Kubernetes [Replica Sets](http://kubernetes.io/docs/user-guide/replicasets/), with support for [Deployments](http://kubernetes.io/docs/user-guide/deployments/) incoming.

![](clusterscreen.png)

# 2. Create a Load Balancer

We will be creating a pair of Spinnaker _Load Balancers_ (Kubernetes [Services](http://kubernetes.io/docs/user-guide/services/)) to serve traffic to our _dev_ and _prod_ versions of our app. Navigate to the _Load Balancers_ tab, and select _Create Load Balancer_ in the top right corner of the screen. 

First we will create the _dev_ _Load Balancer_:

![The fields highlighted in red are the ones we need to fill out. "Port" is the port the load balancer will be listening out, and "Target Port" is the port our server is listening on. "Stack" exists for naming purposes.](devlb.png)

Once the _dev_ _Load Balancer_ has been created, we will create an external-facing load balancer. Select _Create Load Balancer_ again:

![Fill out the fields in red again, changing "Load Balancer IP" to a static IP reserved using your underlying cloudprovider. If you do not have a static IP reserved, you may leave "Load Balancer IP" blank and an ephemeral IP will be assigned.](prodlb.png)

> **If your cloud provider (GKE, AWS, etc...) doesn't support Type: LoadBalancer** 
>
> .... you may need to change _Type_ to _Node Port_. Read more [here](http://kubernetes.io/docs/user-guide/services/#publishing-services---service-types).

At this point your _Load Balancers_ tab should look like this:

![](loadbalancers.png)

# 3. Create a Demo Server Group

Next we will create a _Server Group_ as a sanity check to make sure we have set up everything correctly so far. Before doing this, ensure you have at least 1 tag pushed to your Docker registry with the code you want to deploy. Now on the _Clusters_ screen, select _Create Server Group/Job_, choose _Server Group_ from the drop down and hit _Next_ to see the following dialog:

![Make sure that you select the `-dev` load balancer that we selected earlier.](firstSG1.png)

Scroll down to the newly created _Container_ subsection, and edit the following fields:

![Under the "Probes" subsection, select "Enable Readiness Probe". This will prevent pipelines and deploys from continuing until the containers pass the supplied check and report themselves as "Healthy".](firstSG2.png)

Once the create task completes, open a terminal and type <code>$ kubectl proxy</code>, and now navigate in your browser to http://localhost:8001/api/v1/proxy/namespaces/default/services/serve-dev:80/ to see if your application is serving traffic correctly.

> **kubectl proxy**
>
> `kubectl proxy` forwards traffic to the Kubernetes API server authenticated using your local `~./kube/config` credentials. This way we can peek into what the internal `serve-dev` service is serving on port 80.

Once you're satisfied, don't close the proxy or browser tab just yet as we'll use that again soon.

# 4. Git to _dev_ Pipeline

Now let's automate the process of creating server groups associated with the _dev_ loadbalancer. Navigate to the _Pipelines_ tab, select _Configure_ > _Create New..._ and then fill out the resulting dialog as follows:

![](createdevdeploy.png)

In the resulting page, select _Add Trigger_, and fill the form out as follows:

![The "Organization" and "Image" will likely be different, as you have set up your own Docker repository.

The "Tag" can be a regex matching a tag name patterns for valid triggers. Leaving it blank serves as "trigger on any new tag".](dockertrigger.png)

Now select _Add Stage_ just below _Configuration_, and fill out the form as follows:

![](deploydev.png)

Next, in the _Server Groups_ box select _Add Server Group_, where you will use the already deployed server group as a template like so:

![Any server group in this app can be used as a template, and vastly simplifies configuration 
(since most configuration is copied over). This includes replica sets deployed with "kubectl 
create -f $FILE".](templateselection.png)

In the resulting dialog, we only need to make one change down in the _Container_ subsection. Select the image that will come from the Docker trigger as shown below:

![](configuredynamic.png)

Lastly, we want to add a stage to destroy the previous server group in this _dev_ cluster. Select _Add Stage_, and fill out the form as follows:

![Make sure to select "default" as the namespace, and "toggle for list of clusters" to make cluster selection easier. "Target" needs to be "Previous Server Group", so whatever was previously deployed is deleted after our newly deployed server group is "Healthy".](destroysg.png)

#5. Verification Pipeline

Back on the _Pipelines_ dialog, create a new pipeline as before, but call it "Manual Judgement". On the first screen, add a Pipeline trigger as shown below:

![](judgetrigger.png)

We will only add a single stage, which will serve to gate access to the _prod_ environment down the line. The configuration is shown here:

![](manjudge.png)

Keep in mind, more advanced types of verification can be done here, such as running a Kubernetes batch job to verify that your app is healthy, or calling out to an external Jenkins server. For the sake of simplicity we will keep this as "manual judgement".

# 6. Promote to _prod_

Create a new pipeline titled "Deploy to Prod", and configure a pipeline trigger as shown here:

![](mantrigger.png)

Now we need to find the deployed image in _dev_ that we previously verified. Add a new stage and configure it as follows:

![Select the "default" namespace, the "serve-dev" cluster using "Toggle for list of clusters", and make sure to select "Newest" as the "Server Group Selection". 

"Image Name Pattern" can be used when multiple different images are deployed in a single Kubernetes Pod. Since we only have a single deployed container we can safely use ".*" as the pattern.](fimage.png)

Now, to deploy that resolved image, add a new stage and configure it as follows:

![](proddeploy1.png)

Select _Add Server Group_, and again use the _dev_ deployment as a template:

![](templateselection.png)

This time we need to make three changes to the template. First, change the "stack" to represent our _prod_ cluster:

![](changestack.png)

Next in the load balancers section:

![We want to attach this server group to the "prod" load balancer, so make sure to remove the "dev" load balancer with the trash-can icon, and select the "serve-prod" load balancer in its place.](prodlbse.png)

Lastly in the container section:

![](fimingres.png)

Now to prevent all prior versions of this app in production from serving traffic once the deploy finishes, we will add a "Disable Cluster" stage like so:

![You will need to manualy enter "serve-prod" as the cluster name since it doesn't exist yet.](disablecluster.png)

Save the pipeline, and we are ready to go!

# 7. Run the Pipeline

Push a new branch to your repo, and wait for the pipeline to run.

<code>NEW_VERSION=v1.0.0
 git checkout -b $NEW_VERSION
 git push origin $NEW_VERSION</code>

Once the Manual Judgement stage is hit, open http://localhost:8001/api/v1/proxy/namespaces/default/services/serve-dev:80/ to "verify" your deployment, and hit _continue_ once you are ready to promote to _prod_.

![Selecting "stop" will cause the deployment to fail, and the next pipeline won't trigger.](manjudge2.png)

![Notice that the "Find Image" phase automatically finds the tag that we triggered the first pipeline, as it was the one we verified earlier.](trigfind.png)

![To verify, check the public facing cluster's service's endpoint circled above.](linktocluster.png)
