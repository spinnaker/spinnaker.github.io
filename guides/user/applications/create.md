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

   | Field | Required | Description |
   | --- | --- | --- |
   | Name  | Yes | A unique name to identify this application. |
   | Owner Email | Yes | The email address of the owner of this application, within your installation of Spinnaker. |
   | Repo type | No | The platform hosting the code repository for this application. Stash, Bitbucket, or GitHub. |
   | Description | No | Use this text field to describe the application, if necessary. |
   | Consider only cloud provider health | (Bool, default=no) | If enabled, instance status as reported by the cloud provider is considered sufficient to determine task completion. When disabled, tasks need health status reported by some other health provider (load balancer, discovery service).|
   | Show health override option | Bool, default=no | If enabled, users can toggle previous option per task. |
   | Instance port | No | This field is used to generate links from Spinnaker instance details to a running instance. The instance port can be used or overridden for specific links configured for your application (via the Config screen). |
   | Enable restarting running pipelines | Bool, default=no | If enabled, users can restart pipeline stages while a pipeline is still running. This behavior is not recommended. |

1. Click **Create**.

## Next steps

You now have an application in which to start adding infrastructure and creating
pipelines. These application attributes are the minimum configuration, but you
will probably want to [finish configuring the
application](/guides/user/applications/configure/).
