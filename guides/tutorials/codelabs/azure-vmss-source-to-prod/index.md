---
layout: single
title:  "Azure VM Scale Sets: Source to Prod"
sidebar:
  nav: guides
---

{% include toc %}

In this codelab, you will create a source-to-prod continuous delivery pipeline for a simple java based application targeting VM Scale Sets in Azure.

After completing this lab the following workflow will happen: 
  1. A developer pushes a commit to Github
  2. Jenkins automatically builds a Debian package and pushes it to an Aptly repository
  3. Spinnaker bakes the new package into an image
  4. Spinnaker deploys to a test environment and disables the previous deployment
  4. Spinnaker waits for a manual judgement of the test environment
  5. Spinnaker deploys the image to the production environment and disables the previous deployment.
  
This codelab will walk through the following steps to implement this scenario: 

  * [Deploy Spinnaker and Jenkins on Azure](#1-deploy-spinnaker-and-jenkins-on-azure)
  * [Verify Jenkins](#2-verify-jenkins)
  * [Prepare your environments](#3-prepare-your-environments)
  * [Create the Continuous Delivery pipeline](#4-create-the-continuous-delivery-pipeline)
  * [Trigger your pipeline](#5-trigger-your-pipeline)
  * [Clean up the environment](#6-tear-down)


## 1. Deploy Spinnaker and Jenkins on Azure 

You need the following resources to perform the codelab: 
- **Azure subscription**: You can create one for free using the [Azure Free trial](https://azure.microsoft.com/free/).
- **Spinnaker and Jenkins VM**:

From a shell run the following command that will walk you through all the steps necessary to deploy Jenkins and Spinnaker in Azure.

> NOTE: When running the following script, ensure that you type `vmss` when asked to select the target.

```bash 
bash <(curl -sL https://aka.ms/DeployDevOps)
```
 

In the output of the above script you will find the command to open an SSH tunnel to the DevOps VM that has just been deployed. The command should look like this: 

```bash
ssh -L 8080:localhost:8080 -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 username@fqdn_of_your_devops_vm
```

> NOTE: You will have to enter the password that you have specified in the previous step.


## 2. Verify Jenkins 

1. After you have started your ssh tunnel, navigate to [http://localhost:8080/](http://localhost:8080) on your local machine.
1. The instance should already be unlocked and your first account setup. Login with the credentials you specified when deploying the template.
1. Click **Install suggested plugins**: 
   ![Install Jenkins plugins](images/2-Install-Jenkins-plugins.png)
1. Your Jenkins instance is now ready to use!
1. Run the `Sample Aptly Job` by clicking on the run button for the job. Verify that the job completes successfully.

   ![Run Jenkins job](images/2-run-sample-aplty-job.png)

## 3. Prepare your environments

### I. Create the "codelab" application 

1. Navigate to your Spinnaker dashboard by using [http://localhost:9000](http://localhost:9000) on your local machine. 
1. Click on the **Actions** menu on the right

   ![Actions](images/3-actions-create-applications.png)
   
1. In the *New Application* window, enter the following values: 
  * Name: codelab
  * Owner Email: Enter your email
  
    And click **Create**
  
    ![New Application](images/3-create-application.png)
  
    You can read more how the Spinnaker application matches to Azure resources in the [Azure reference for Spinnaker](/reference/providers/azure/)

### II. Create a firewall

1. Navigate to the [FIREWALLS](http://localhost:9000/#/applications/codelab/firewalls) page and click on the **Create Firewall** button.
1. Provide the following values in the *Create New Firewall* dialog: 
  * Detail: web
  * Account: my-azure-account (should be selected by default)
  * Region: westus (select the region that is closest to your location)

    Ingress (click *Add new Firewall Rule*):
  * Protocol: TCP
  * Start Port: 80
  * End Port: 80 

    And click **Create**, if the loadbalancer does not appear in the page once the creation is complete, refresh your browser.

    ![New Firewall](images/3-create-firewall.png)

  > Note: We are using westus for the region but you can select any other region that is closer to your location. Be careful to match the region in the following steps.

  You can read more about the implementation of Network Security Groups in Azure in the [Azure reference for Spinnaker](/reference/providers/azure/)

### III. Create a load balancer

1. Navigate to the [LOAD BALANCERS](http://localhost:9000/#/applications/codelab/loadBalancers) page and click the **Create Load Balancer** button.
1. Provide the following values in the "Create New Load Balancer" dialog: 
  * Account: my-azure-account
  * Region: westus (unless you have selected a different region previously)
  * Virtual Network: devopsVnet
  * Subnet: devopsSubnet1
  * Stack: test 
  * Detail: frontend

    Verify that the Listener is configured as follows: 
  * Protocol: HTTP
  * External Port: 80
  * Internal Port: 8080 

    And click **Create**.

    ![Create test load balancer](images/3-create-test-load-balancer.png)

    The virtual network *devopsVnet* and the subnets *devopsSubnet#* were created for you by the script that you ran in the [Deploy Spinnaker and Jenkins on Azure](#1-deploy-spinnaker-and-jenkins-on-azure) step.

    You can learn more about the implementation of the Spinnaler Load Balancer in the [Azure reference for Spinnaker](/reference/providers/azure/).


1. Repeat the above steps to create a second load balancer for production. Use the same parameters but the following change:
  * Stack: prod 

    ![Create prod load balancer](images/3-create-prod-load-balancer.png)

> NOTE: It will take approximately 15 minutes to provision the two loadbalancers.

## 4. Create the continuous delivery pipeline

In this section you will create a Spinnaker pipeline that will bake the image from a Jenkins build then deploy it to test.

### I. Create a new pipeline

1. Navigate to the [PIPELINES](http://localhost:9000/#/applications/codelab/executions) page and click on the *New* button (+ sign) on the right to create a new pipeline.
1. Name your pipeline: "Deploy codelab" and click **Create**.

   ![Bake and Deploy to Test](images/4-create-new-pipeline.png)

### II. Add a trigger for the pipeline

1. Click *Add Trigger* in the *Deploy codelab* window.
1. Select the following options: 
  * Type: "Jenkins"
  * Master:  "Jenkins" 
  * Job: "hello-karyon-rxnetty"
  * Property File: leave empty 

    ![Add a trigger](images/4-add-trigger.png)

### III. Add *Bake* stage

1. Click *Add stage* in the *Deploy codelab* window.
1. Enter the following values: 
  * Type: Bake
  * Stage Name: Bake
  * Regions: westus (or select the region that you have selected when creating the Firewall)
  * Package: ```hello-karyon-rxnetty```
  * Base OS: ubuntu (v14.05)

    ![Add Bake](images/4-add-bake-stage.png)

### IV. Add *Deploy to test* stage

1. Click *Add stage*
1. Enter the following values: 
  * Type: Deploy
  * Stage Name: Deploy to Test
  * Depends On: Bake

    ![Add Deploy to Test](images/4-add-deploy-to-test.png)

### V. Create test deployment configuration

1. Click *Add server group* in the Deploy Configuration section. 

   ![Add server group](images/4-add-server-group.png)

1. Click "Continue without a template"
1. In the "Configure Deployment Cluster" enter the following values:
  * Account: my-azure-account
  * Region: westus (or select the region that you have selected when creating the Firewall)
  * Stack: test
  * Details: tutorial
  * Load Balancers: codelab-test-frontend

    ![Configure Deployment Cluster - 1](images/4-configure-deployment-cluster-1.png)
    
  * Subnets: devopsSubnet2
  * Firewalls: codelab-web

    ![Configure Deployment Cluster - 2](images/4-configure-deployment-cluster-2.png)

  * "Advanced Settings": 
    - Custom Data: TEST
    - Custom Script: https://raw.githubusercontent.com/azure-devops/hello-karyon-rxnetty/master/scripts/setcustomenv.sh
    - Command To Execute: sudo bash ./setcustomenv.sh

      ![Configure Deployment Cluster - 3](images/4-configure-deployment-cluster-3.png)

  * Click **Add** 

> NOTE: Record the name of the cluster. it will be used in the next step.

### VI. Enable test deployment 

1. Click *Add stage* in the *Deploy codelab* section.
1. Enter the following values: 
  * Type: Enable Server Group
  * Stage Name: Enable Test Deployment
  * Depends On: Deploy to Test
  * Account: my-azure-account
  * Regions: westus (or select the region that you have selected when creating the Firewall)
  * Cluster: codelab-test-tutorial (or the name of your cluster if you have used different values)
  * Target: Newest Server Group

    ![Enable test Deployment](images/3-enable-test-deployment.png)

### VII. Manual judgment 

1. Click *Add stage* in the *Deploy codelab* section.
1. Use the following values: 
  * Type: Manual Judgment
  * Name: Manual Judgment
  * Depends On: Enable Test Deployment
  * Instructions: Validate test cluster 

### VIII. Add Deploy to Prod stage

1. Click *Add stage* in the *Promote to Prod* section. 
1. Use the following values to configure the stage:
  * Type: Deploy
  * Stage Name: Deploy to Prod
  * Depends On: Manual Judgment

### IX. Create production deployment configuration 

1. Click *Add server group* in the Deploy Configuration section. 
1. Click *Continue without a template*
1. In the *Configure Deployment Cluster* enter the following values:
  * Account: my-azure-account
  * Region: westus (or select the region that you have selected when creating the Firewall)
  * Stack: prod
  * Details: tutorial
  * Load Balancers: codelab-prod-frontend

    ![Configure Prod Cluster - 1](images/4-configure-prod-cluster-1.png)

  * Subnets: devopsSubnet2
  * Firewalls: codelab-web

    ![Configure Prod Cluster - 2](images/4-configure-deployment-cluster-2.png)

  * "Advanced Settings": 
    - Custom Data: PROD
    - Custom Script: https://raw.githubusercontent.com/azure-devops/hello-karyon-rxnetty/master/scripts/setcustomenv.sh
    - Command To Execute: sudo bash ./setcustomenv.sh
  
      ![Configure Deployment Cluster - 3](images/4-configure-prod-cluster-2.png)

  * Click **Add** 

> NOTE: Record the name of the cluster. it will be used in the next step.

### X. Enable prod deployment

1. Click *Add stage* in the *Deploy codelab* section.
1. Use the following values to configure this stage: 
  * Type: Enable Server Group
  * Stage Name: Enable Prod Deployment
  * Depends On: Deploy to Prod
  * Account: my-azure-account
  * Regions: westus (or select the region that you have selected when creating the Firewall)
  * Cluster: codelab-prod-tutorial
  * Target: Newest Server Group

    ![Enable Prod deployment](images/4-enable-prod-deployment.png)

  * Click **Save Changes**

## 5. Trigger your pipeline 

In this step you will try out the pipeline that you have just built. 

1. Go to [Jenkins](http://localhost:8080) and start a new build of the "Sample Aptly Job" like you did in the section "[Verify Jenkins](#2-verify-jenkins)". You should see your Spinnaker pipeline running soon after your Jenkins job finishes. 

1. Navigate to the [PIPELINES](http://localhost:9000/#/applications/codelab/executions) tab
1. Click on *Details* to get more information about the status of your deployment
1. Connect to your application. 
   You can find the public name of your application by looking at the DNS Name that has been assigned to your load balancer.

   ![DNS Name of your application](images/5-application-dns-name.png) 

## 6. Tear Down

### I. Delete your pipeline 

1. In the configuration of your pipeline, click on *Pipeline Actions* then click on *Delete*

   ![Delete pipeline](images/6-delete-pipeline.png)

### II. Delete your server groups 

1. Navigate to the [CLUSTERS](http://localhost:9000/#/applications/codelab/clusters) section.
1. Select each Server Group in the list and select *Destroy* for each of them. 

   ![Destroy Server Group](images/6-destroy-server-group.png)

### III. Delete your load balancers

1. Navigate to the [LOAD BALANCERS](http://localhost:9000/#/applications/codelab/loadBalancers) section.
1. Select each Load Balancer in the list then in the *Load Balancer Actions* select *Delete Load Balancer* 

   ![Delete Load Balancer](images/6-delete-load-balancer.png)

### IV. Delete your firewall

1. Navigate to the [FIREWALL](http://localhost:9000/#/applications/codelab/firewalls) section.
1. Select each Firewall in the list then in the *Firewall Actions* select *Delete Firewall* 

   ![Delete Firewall](images/6-delete-firewall.png)
