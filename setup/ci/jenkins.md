---
layout: single
title:  "Jenkins"
sidebar:
  nav: setup
redirect_from: /docs/jenkins-script-execution-stage
---

{% include toc %}

Setting up [Jenkins](https://jenkins.io/){:target="\_blank"} as a Continuous
Integration (CI) system within Spinnaker lets you trigger pipelines with
Jenkins, add a Jenkins stage to your pipeline, or add a Script stage to your
pipeline.

## Prerequisites

To connect Jenkins to Spinnaker, you need:

*   A running Jenkins Master at version 1.x - 2.x, reachable at a URL
    (`$BASEURL`) from the provider that Spinnaker will be deployed in.
*   A username/password (`$USERNAME`/`$PASSWORD`) pair able to authenticate
    against Jenkins using HTTP Basic Auth, if Jenkins is secured.

## Add your Jenkins master

1. First, make sure that your Jenkins master is enabled:

   ```bash
   hal config ci jenkins enable
   ```

1. Next, add Jenkins master named `my-jenkins-master` (an arbitrary,
human-readable name), to your list of Jenkins masters:

   ```bash
   echo $PASSWORD | hal config ci jenkins master add my-jenkins-master \
       --address $BASEURL \
       --username $USERNAME \
       --password # password will be read from STDIN to avoid appearing
                  # in your .bash_history
   ```

   > *Note*: If you use the [GitHub OAuth
   > plugin](https://wiki.jenkins.io/display/JENKINS/GitHub+OAuth+Plugin){:target="\_blank"}
   > for authentication into Jenkins, you can use the GitHub $USERNAME, and use the
   > OAuth token as the $PASSWORD.

1. Re-deploy Spinnaker to apply your changes:

   ```bash
   hal deploy apply
   ```

## Configure Jenkins and Spinnaker for CSRF protection

> **NOTE:** Jenkins CSRF protection in Igor is only supported for Jenkins 2.x.

To enable Spinnaker and Jenkins to share a crumb to protect against CSRF...

1. Configure Halyard to enable the `csrf` flag:

    ```
    hal config ci jenkins master edit MASTER --csrf true
    ```

    (`MASTER` is the name of the Jenkins master you've previously
    configured. If you haven't yet added your master, use `hal config ci
    jenkins master add` instead of `edit`. )

    Here's what your Jenkins master configuration looks like in your Hal config:

    ```yaml
    jenkins:
          enabled: true
          masters:
          - name: <jenkins master name>
            address: http://<jenkins ip>/jenkins
            username: <jenkins admin user>
            password: <admin password>
            csrf: true
    ```

    Be sure to invoke `hal deploy apply` to apply your changes.

2. Enable CSRF protection in Jenkins:

    a. Under __Manage Jenkins__ > __Configure Global Security__, select __Prevent
    Cross Site Request Forgery exploits__.

    b. Under __Crumb Algorithm__, select __Default Crumb Issuer__.

    ![](/setup/ci/jenkins_enable_csrf.png)

## Next steps

You can use Jenkins in your pipelines in one of three ways:
*   As a [pipeline trigger](/guides/user/pipeline/triggers/jenkins/)
*   Using the built-in [Jenkins stage](/reference/pipeline/stages/#jenkins)
*   Using the [Script stage](/reference/pipeline/stages/#script)

After you've completed the setup above, you're ready to trigger pipelines with
Jenkins or run the Jenkins stage. This is sufficient for most use cases. See
[Triggering Pipelines with Jenkins](/guides/user/pipeline/triggers/jenkins/)
for more information.

Using the Script stage requires further configuration. See [Configuring
the Script Stage](/setup/features/script-stage/) to finish setting it up.
