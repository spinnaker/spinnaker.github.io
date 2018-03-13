---
layout: single
title:  "Bake and Deploy Pipeline"
sidebar:
  nav: guides
redirect_from: /docs/bake-and-deploy-pipeline
---

{% include toc %}

> **NOTE:** _Kubernetes:_ The following example pipeline is predicated on running a VM based deployment solution (e.g. AWS, GCP). Comprehensive documentation of pipeline configuration for Kubernetes is incoming, as it is slightly different for container based solutions.

To walk you through some of the basics with Spinnaker, you're going to set up a Spinnaker pipeline that bakes a virtual machine (VM) image containing redis, then deploys that image to a test cluster.

Note here that the us-east-1a availability zone is currently full, so it will need to be deselected in the corresponding 'region' checkbox list for each of these steps.

### Create a Spinnaker application

1. In Spinnaker, click **Actions** > **Create Application**
  1. Input <code>example</code> for the **Name** field and your email address for
the **Owner Email** field.
3. Click on the **Consider only cloud provider health when executing
  tasks** button next to **Instance Health**.
4. Click the **Create** button.

### Create and configure a security group

Next, you'll create a security group that specifies traffic firewall
rules for the cluster. You'll configure the firewall rules to allow
all incoming traffic on port 80, for clusters associated with this
security group.

1. Click **SECURITY GROUPS**, then click the **+** button to create a security group.
2. Input <code>test</code> for the **Detail (optional)** field and
<code>Test environment</code> for the **Description** field.
3. If running on AWS
  * Select **defaultvpc** as the **VPC** field
  * Click **Add new Security Group Rule**.
  * Click **default** on the **Security Group** dropdown.
  * Change **Start Port** and **End Port** to <code>80</code>.
4. If running on GCP
  * Click **Add New Source CIDR** and use the default
    <code>0.0.0.0/0</code> value for the **Source Range** field.
  * Click **Add New Protocol and Port Range**. Use the default
  <code>TCP</code> value for the **Protocol** field. Change **Start
  Port** and **End Port** to <code>80</code>.
5. Click the **Create** button.

### Create a load balancer

Next, you'll create a load balancer in Spinnaker.

1. Click **LOAD BALANCERS**, then click the **+** button to create a load balancer.
2. Input <code>test</code> for the **Stack** field.
3. If running on AWS, select **internal (defaultvpc)** from the **VPC
  Subnet** dropdown.
4. Click the **Next** button.
5. If running on AWS
  * Select **example-test** from the **Security Groups** dropdown.
  * Hit **Next**, then **Create**.
6. If running on GCP
  * Deselect the **Enable health check?** checkbox.
7. Click the **Create** button.

### Create a deployment pipeline

Your final task is to set up a Spinnaker pipeline. Let's name it
**Bake & Deploy to Test**. The pipeline will produce an image
containing the <code>redis-server</code> package and then deploy
it. In this tutorial, you'll trigger the pipeline manually.

To create the pipeline:

1. Click **PIPELINES**, then click **Configure** and select **Create
  New...** from the dropdown.
2. Input <code>Bake & Deploy to Test</code> for the **Pipeline Name**.
3. Click the **Create Pipeline** button.

#### Set up the first stage of the pipeline

You're now going to create the first stage of the pipeline. It will
build an image from an existing redis-server package.

1. Click **Add stage**.
2. Select **Bake** from the **Type** pulldown menu.
3. Input <code>redis-server</code> for the **Package** field.
4. Click **Save Changes**.

#### Set up the second stage of the pipeline

You're now going to set up the second stage of the pipeline. It takes
the image constructed in the *Bake* stage and deploys it into a test
environment.

1. Click **Add stage**.
2. Select **Deploy** from the **Type** dropdown.
3. Under the **Server Groups** heading, click **Add server group**.
4. Click the **Continue without a template** button.

Next, In the **Configure Deployment Cluster** window, input "test"
for the **Stack** field.

6. If running on AWS, select **defaultvpc** under **VPC Subnet**.
7. Click the **Next** button.
8. Click the text area next to the **Load Balancers** heading, then
  select <code>example-test</code>. Click the **Next** button.
9. Click the **Security Groups** form field, then click
  <code>example-test (example-test)</code>. Click the **Next**
  button.
10. If running on AWS
  * Click on the **Micro Utility** button to set the **Instance
    Profile**, then click **Next**.
  * Select the **Medium: m3** size, then click **Next**.
11. If running on GCP
  * Click on the **Micro Utility** button to set the **Instance
    Profile**, then click **Next**.
  * If running on GCP, select the **Micro** size, then click **Next**.
12. Input <code>2</code> for the **Number of Instances** field, then click the
  **Add** button.
13. Save the pipeline configuration by clicking the **Save Changes**
  button.

### Try it out!

1. Click **PIPELINES** in the navigation bar.
2. Click **Start Manual Execution** for the **Bake & Deploy to Test**
  pipeline.
3. Click **Run**.

Now, watch Spinnaker in action. A **MANUAL START** section will
appear, and will show progress as the pipeline executes. At any point
during pipeline execution, click on the horizontal bar to see detailed
status for any of the stages in the pipeline.

Feel free to navigate around the Spinnaker menus, create new
pipelines, clusters, server groups, load balancers, and security
groups, etc. and see what happens.

When you're ready to stop, don't forget to cleanup your resources. An
easy way to do this is to visit the pipelines, clusters, load
balancers, and security groups pages, click on the ones created and
select the appropriate **Delete** command from the Actions pulldown on
the right.
