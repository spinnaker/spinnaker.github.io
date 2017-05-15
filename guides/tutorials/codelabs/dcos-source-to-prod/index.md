---
layout: single
title:  "DC/OS: Source to Prod"
sidebar:
  nav: guides
---

{% include toc %}


# 0. Setup

## Prerequisites

- Github repository with the source code to deploy
- Enterprise DC/OS cluster (1.8 or greater)
  - Marathon-lb is should be installed and running
  - For the examples in this codelab we'll say that it's at `https://dcos.example.com` so you should replace that with the URL to your cluster
- Jenkins instance
  - This can be installed on your DC/OS cluster as a [Mesosphere Universe package](https://docs.mesosphere.com/service-docs/jenkins/)


## Configure Spinnaker

### Manual

#### clouddriver-local.yml

```yml
dcos:
  enabled: true
  clusters:
    - name: codelab-cluster
      dcosUrl: https://dcos.example.com
      insecureSkipTlsVerify: true
  accounts:
    - name: codelab-dcos-account
      dockerRegistries:
        - accountName: my-docker-registry
      clusters:  
        - name: codelab-cluster
          uid: ${DCOS_USER}
          password: ${DCOS_PASSWORD}
dockerRegistry:
  enabled: true
  accounts:
  - name: my-docker-registry
    address: https://index.docker.io
    repositories:
    - lwander/spin-kub-demo
    username: ${DOCKER_USER}
    password: ${DOCKER_PASSWORD}
```

### Halyard  

If you've deployed your Spinnaker instance with Halyard, configuring Spinnaker requires the following steps.

#### Enable Docker

[Configure a docker registry with halyard](https://spinnaker.github.io/setup/providers/docker-registry/)

#### Set up the DC/OS provider

First, enable the provider:

```bash
hal config provider dcos enable
```  

Next we need to add our DC/OS cluster:

```bash
hal config provider dcos cluster add codelab-cluster \
    --dcos-url $CLUSTER_URL \
    --skip-tls-verify # For simplicity we won't worry about the
    # certificate for the cluster but this would not be recommended
    # for a real deployment
```

Create a Spinnaker account that has credentials for the cluster.

```bash
hal config provider dcos account add codelab \
    --cluster codelab-cluster \
    --docker-registries my-docker-registry \
    --uid $DCOS_USER \
    --password $DCOS_PASSWORD
```

* Note: Make sure that your DC/OS user has permission to deploy applications under a `/codelab` group in Marathon

And deploy the config with `hal`

```bash
sudo hal deploy apply
```

# 1. Create a Spinnaker Application

Spinnaker applications are groups of resources managed by the underlying cloud provider, and are delineated by the naming convention `<app name>-`.

Under the _Actions_ dropdown select _Create Application_ and fill out the following dialog:

![If you've followed the Source to Prod tutorial for the VM based providers, you'll remember that you needed to select "Consider only cloud provider health when executing tasks". Since DC/OS is the sole health provider by definition, selecting this here is redundant, and unnecessary.](images/100-createapp.png)

You'll notice that you were dropped in this _Clusters_ tab for your newly created application. In Spinnaker's terminology a _Cluster_ is a collection of _Server Groups_ all running different versions of the same artifact (Docker Image). Furthermore, _Server Groups_ are DC/OS  [Services](https://docs.mesosphere.com/1.9/deploying-services/creating-services/)

![](images/101-clusters.png)

# 2. Create a Demo Server Group

Next we will create a _Server Group_ as a sanity check to make sure we have set up everything correctly so far. Before doing this, ensure you have at least 1 tag pushed to your Docker registry with the code you want to deploy. Now on the _Clusters_ screen, select _Create Server Group/Job_, choose _Server Group_ from the drop down and hit _Next_ to see the following dialog:

![](images/200-server-group-blank.png)

Fill out the basic settings and select your Docker image to use.

![](images/201-basics.png)

Select the Bridge network type and the port that the process in the container will listen on.

![](images/202-network.png)

Add the labels that marathon-lb will use to route traffic to your instance.

![](images/203-labels.png)

Finally, add a health check and then click Create.

![](images/204-healthcheck.png)

Test that you can reach your service with the following command (where `$VHOST` is the `HAPROXY_0_VHOST` value from your server group)

```bash
curl --header "Host: dev.example.com" http://$PUBLIC_AGENT
```

# 3. Git to _dev_ Pipeline

Now let's automate the process of creating server groups associated with the _dev_ stack. Navigate to the _Pipelines_ tab, select _Configure_ > _Create New..._ and then fill out the resulting dialog as follows:

![](images/300-new-pipeline.png)

In the resulting page, select _Add Trigger_, and fill the form out as follows:

![The "Organization" and "Image" will likely be different, as you have set up your own Docker repository. The "Tag" can be a regex matching a tag name patterns for valid triggers. Leaving it blank serves as "trigger on any new tag".](images/301-docker-trigger.png)

Now select _Add Stage_ just below _Configuration_, and fill out the form as follows:

![](images/302-deploy-stage.png)

Next, in the _Server Groups_ box select _Add Server Group_, where you will use the already deployed server group as a template like so:

![Any server group in this app can be used as a template, and vastly simplifies configuration (since most configuration is copied over).](images/303-template.png)

In the resulting dialog, we only need to make one change down in the _Container_ subsection. Select the image that will come from the Docker trigger as shown below:

![](images/304-container-tag.png)

Lastly, we want to add a stage to destroy the previous server group in this _dev_ cluster. Select _Add Stage_, and fill out the form as follows:

![Make sure to select "codelab-cluster" as the region, and "toggle for list of clusters" to make cluster selection easier. (For DC/OS in Spinnaker a "region" is a DC/OS cluster and a "cluster" is a Spinnaker concept for managing server groupp) "Target" needs to be "Previous Server Group", so whatever was previously deployed is deleted after our newly deployed server group is "Healthy".](images/305-destroy.png)

# 4. Verification Pipeline

Back on the _Pipelines_ dialog, create a new pipeline as before, but call it "Manual Judgement". On the first screen, add a Pipeline trigger as shown below:

![](images/400-pipeline-trigger.png)

We will only add a single stage, which will serve to gate access to the _prod_ environment down the line. The configuration is shown here:

![](images/401-manual-judgment.png)

Keep in mind, more advanced types of verification can be done here, such as running a DC/OS batch job to verify that your app is healthy, or calling out to an external Jenkins server. For the sake of simplicity we will keep this as "manual judgement".

# 5. Promote to _prod_

Create a new pipeline titled "Deploy to Prod", and configure a pipeline trigger as shown here:

![](images/500-prod-trigger.png)

Now we need to find the deployed image in _dev_ that we previously verified. Add a new stage and configure it as follows:

![Select the "codelab-cluster" region, the "" cluster using "Toggle for list of clusters", and make sure to select "Newest" as the "Server Group Selection".](images/501-find-image.png)

Now, to deploy that resolved image, add a new stage and configure it as follows.

Select _Add Server Group_, and again use the _dev_ deployment as a template:

![](images/502-template.png)

This time we need to make three changes to the template. First, change the "stack" to represent our _prod_ cluster:

![](images/503-prod-stack.png)

Next in the container section:

![Select the image from the Find Image stage results](images/504-prod-image.png)

Lastly in the labels section:

![Change the label so that marathon-lb will route traffic from our prod vhost to instances in this server group](images/505-prod-vhost.png)

Now to prevent all prior versions of this app in production from serving traffic once the deploy finishes, we will add a "Disable Cluster" stage like so:

![You will need to manualy enter "codelab-prod" as the cluster name since it doesn't exist yet.](images/506-prod-disable.png)

Save the pipeline, and we are ready to go!

# 7. Run the Pipeline

Push a new branch to your repo, and wait for the pipeline to run.

<code>NEW_VERSION=v1.0.0
 git checkout -b $NEW_VERSION
 git push origin $NEW_VERSION</code>

Once the Manual Judgement stage is hit, use `curl` to "verify" your deployment.

```bash
curl --header "Host: dev.example.com" http://$PUBLIC_AGENT
```

Hit _continue_ once you are ready to promote to _prod_.

![Selecting "stop" will cause the deployment to fail, and the next pipeline won't trigger.](images/700-continue.png)

![Notice that the "Find Image" phase automatically finds the tag that we triggered the first pipeline, as it was the one we verified earlier.](images/701-image-found.png)

To verify, use `curl` again:

```bash
curl --header "Host: prod.example.com" http://$PUBLIC_AGENT
```

Once the pipelines are done, you can see the dev and prod stacks in the _Clusters_ tab:

![](images/702-done.png)
