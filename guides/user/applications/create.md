---
layout: single
title:  "Create an application"
sidebar:
  nav: guides
---

You can't create a deployment pipeline unless you have an application to put it
in. If you're accessing Spinnaker for the first time and there are no
applications available, the first thing you're going to do is create one.

1. From any screen, click on the **Applications** tab.

   Note that there might be some applications there already. In some cases,
   Spinnaker creates applications automatically based on existing
   infrastructure.

   These applications will be marked "unconfigured"; they won't have the
   application attributes that are added when you create a new application.
   These inferred applications are not suitable for putting your pipelines in;
   go ahead and create a new one.

1. Click **Actions**, then **Create Application**.

   ![](/guides/user/applications/create_application.png)

1. Provide the application attributes in the **New Application** dialog.

   * Provide a **Name**

     This name can't be changed later.

   * **Owner Email** is your email address, or that of someone else who will own
   this application.

   * **Repo Type** tells Spinnaker where to find your repository.

   * **Description** can be anything you want, but should help others understand
   what this application is for.

   * **Instance Health** tells Spinnaker how to assess the health of the instance
   you're deploying to.

     - **Consider only cloud provider...** if activated, tells Spinnaker to rely
     only on the machine itself to report its health. This is the easier option,
     and is recommended for development. If not selected, Spinnaker uses the
     health provider configured in your load balancer. This is a more thorough
     check and is recommended for production.

     - **Show health override** lets you choose the health check separately for
     each task.

   * The **Instance Port** gives the default port number, on the deployed instance,
   that Spinnaker will use when constructing links on the instance's detail view.

   * **Enable restarting running pipelines**, if selected, lets you restart stages
   while the pipeline is running. *Not recommended*.

1. Click **Create**.

## Next steps

You now have an application in which to start adding infrastructure and creating
pipelines. These application attributes are the minimum configuration, but you
will probably want to [finish configuring the
application](/guides/user/applications/configure/).
