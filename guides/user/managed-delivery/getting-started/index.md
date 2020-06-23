---
layout: single
title:  "Getting Started"
sidebar:
  nav: guides
redirect_from: /reference/managed-delivery/getting-started/
---

{% include toc %}

Managed Delivery is currently in Alpha. 
This means that we support only EC2 and Titus, and that we have limited feature and UI support.
This guide walks through onboarding to Managed Delivery assuming that you are using EC2 or Titus.


## Intro

To get started with Managed Delivery you'll need an idea of what infrastructure you want to manage.
You can pick a new piece of infrastructure that you want to create (a new load balancer, for example) or migrate an existing piece of infrastructure (an existing cluster, for example).

We recommend creating a new security group to test things out.
This guide will walk you through creating a new managed security group.

Here are the steps you'll complete:
1. First, you'll create a YAML file to store your delivery config in.
2. Then, you'll set up a Spinnaker pipeline to submit that YAML file to Spinnaker.
3. Finally, you'll watch Spinnaker take actions to make your resource exist.

## Background

Right now, most users manage infrastructure resources in the Spinnaker UI.
These resources are security groups, load balancers, and clusters.
To create these resources you manually define them by clicking the `create` button in the Spinnaker UI.

Managed Delivery changes this interaction.
To define resources that Spinnaker manages, you'll create a YAML-based "delivery config" file specifying the desired state of your infrastructure resources.
"Desired state" is a new concept in Spinnaker that means you're specifying **what** you want your infrastructure to always look like, regardless of **how** Spinnaker decides to make it look that way.
In practice, this desired state will often look like the configuration options you're used to defining through the Spinnaker UI.

> :bulb: To learn more about delivery configs, check out <a href="/guides/user/managed-delivery/delivery-configs/" target="_blank">this section</a>
> of the documentation.

Once you create a YAML delivery config, you'll need to tell Spinnaker to manage it. 
This is done by submitting the file to Spinnaker's API.
You can submit a delivery config from your local machine, but that's not very traceable or repeatable.

We recommend checking delivery configs into your git repository in a `.spinnaker/` directory at the base level of your repository.
In order to get Spinnaker to pick up your configuration (and monitor for changes) you should create a git-triggered pipeline that submits those files to Spinnaker.

**An important note**: Spinnaker is the source of truth for desired state of resources.
You must submit your YAML files to Spinnaker every time they change.

All the instructions for this flow are captured in this doc. 

Let's get started!

## Prerequisites

Spinnaker takes a lot of actions on your behalf, and we do that by using the permissions of a service account.
Make sure you have one set up before you continue.


## Create Your First Resource

We're going to create a test security group.
The new security group will be called `YOUR_APP-md`.
For example, if the app that you're using is `keeldemo` then the security group will be `keeldemo-md`.

We're going to base this security group on your existing application security group.
If you want to, locate your application security group in the Spinnaker UI and inspect the rules you have on it. 
This security group is usually auto-created for you and is identical to the name of your app.

To create a resource definition based on this security group, we're going to use the Spinnaker API to export your existing application security group to a YAML definition 
(Note: this will have UI support in the future).

The base URL for exporting a security group is:

```
/managed/resources/export/aws/AWS_ACCOUNT_NAME/securitygroup/APP_NAME_OR_SG_NAME?serviceAccount=SERVICE_ACCOUNT
```

* Replace `AWS_ACCOUNT_NAME` with the account your app is in. You can check the [credentials]
endpoint in Spinnaker API for a list of valid account names.
* Replace `APP_NAME_OR_SG_NAME` with either the name of your application or the name of the
security group you want to export. You probably have a security group with the same name as
your app, which is the one you should use here.
* Replace `SERVICE_ACCOUNT` with the same service account you created or found in the
[prerequisites](#prerequisites) step.

If you've gotten all the information right a resource configuration will show up. See the [API]
docs for more information on usage. 

[credentials]: /reference/api/docs.html#api-Credentialscontroller-getAccountsUsingGET
[API]: /guides/user/managed-delivery/api#export-an-existing-resource

## Save Your Resource In Your Git Repository

The next step in managing a resource is to check it into a git repository.
Create a `.spinnaker/` directory in the git repository of your application. 
This should be at the top level of your repo. 
In this directory, create a file called `spinnaker.yml` (your delivery config) and paste in this skeleton delivery config:

```yaml
name: a-manifest-name # change me
application: yourapp # change me
artifacts: []
environments: 
  - name: testing # this is a fine default but you can change it
    constraints: []
    notifications: []
    resources: []
```
Be sure to change the manifest *name* (a human readable name) and the *application* to your app.
You can also change the environment name.

Next, we will add the security group to the list of resources.

Paste in the YAML output you got from the export endpoint in the previous step into the list of resources.
It'll look something like this:

```yaml
name: a-manifest-name
application: yourapp
artifacts: []
environments: 
  - name: testing
    constraints: []
    notifications: []
    resources: # you can add more resources here, this is a list
    - apiVersion: ec2.spinnaker.netflix.com/v1
      kind: security-group
      # ... the other info here from the security group you just exported 
```

Next, modify the resource you just added to have a new name! 
Edit the `moniker` section of the resource you just pasted:

```yaml
...
    moniker:
      app: YOUR_APP_NAME
      stack: md
...
``` 

This will name your security group `YOUR_APP_NAME-md`. 
For example, my sample security group for my app `keeldemo` will have a moniker section like:

```yaml
...
    moniker:
      app: keeldemo
      stack: md
...
```  

which will name the security group `keeldemo-md`.

:stop_sign: **STOP! Don't commit your delivery config yet! Just save it locally.**


## Repository Permissions

Make sure your git repository is accessible by Spinnaker.


## Setting Up Resource Submission

Since Spinnaker is the source of truth (and not Git) you need to submit your managed resource configuration to Spinnaker every time there are changes.
There's a Spinnaker stage for this!
See the docs on [Git-based-workflows](/guides/user/managed-delivery/git-based-workflows/) for detailed instructions.


## Testing Out Resource Submission

Now that you have a pipeline in your application that's triggered off of a git commit to your repository, you can commit your first resource configuration file.
Commit the file you created earlier (`.spinnaker/spinnaker.yml`) and push it to the master branch of your repository. 


## Iterating on Managed Configurations

It's hard to get YAML right every time.
We have an endpoint where you can check if your YAML is right and see if there is a diff between your desired state (in your YAML) and the current state of the resource.

In the swagger api view of your Spinnaker intsance, scroll to the `managed-controller` and find the `/managed/delivery-configs/diff` endpoint. 

Paste in your delivery config YAML file, choose `application/x-yaml` for the content type, and hit `execute`. 
If the resource YAML has an invalid format, you'll get an error back with the reason why.
If the resource YAML is correct, you'll see some information about whether or not there is a diff, and what that diff is.

For more help with this endpoint, see the the [API](/guides/user/managed-delivery/api/#validating-yaml) doc.

## Is Anything Happening?

You can see the actions Spinnaker is taking on your behalf in the `Tasks` view for your app. 

If you navigate to `Security Groups` you should be able to see a small flag on the resource that will show you it's being manged.
If you click on a managed resource you will see the available managed actions.

Under the actions you can click to see the resource definition that Spinnaker has for that resource.
You can also see the history of that resource. 
The history view shows every diff Spinnaker has seen, and every action taken to resolve that diff.
 
 
## Find Your Resource ID

For some API calls you need the resource ID. 
You can find this by clicking on the resource in the UI, and then clicking on `Resource Actions` -> `Raw Source` (right side on the panel that pops out).
The ID will be in the the `metadata` section and will be human readable, like `ec2:cluster:test:keeldemo-main`.


## Pausing Management

Sometimes you need to take a break.
Maybe there's a problem you're trying to diagnose and you need Spinnaker to stop taking actions on a resource.
Maybe there's a bug and it's preventing you from using Spinnaker to manage resources.
That's ok! It's easy to pause management.

Navigate to your application in Spinnaker and click on the `CONFIG` tab in the top right.
If you have 1 or more managed resources, a section will appear called `Managed Resources`. 
That section contains a pause/resume button which you can use to stop and start management of your Resources. 


## Cleaning Up / Opting Out

If you don't want Spinnaker to manage your resource declaratively anymore you can delete the declarative config from Spinnaker:

```bash
DELETE /managed/delivery-configs/{deliveryConfigName}
```

This endpoint is available in the Swagger UI as well. 

**This will not delete the underlying infrastructure that was previously in your delivery config. It will only delete the managed definition and stop Spinnaker from taking action.**
Use the Spinnaker UI to delete any resources you created.

## Next Steps

Hooray! 
You created your first managed resource. 
If you'd like, you can follow these same steps to create clusters, load balancers, and security groups for your application.
You can add resources to the environment you've created by added them to the list of resources. 
