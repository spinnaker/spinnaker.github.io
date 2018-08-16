---
layout: single
title:  "Jenkins"
sidebar:
  nav: setup
redirect_from: /docs/jenkins-script-execution-stage
---

{% include toc %}

Setting up [Jenkins](https://jenkins.io/){:target="\_blank"} as a Continuous
Integration (CI) system within Spinnaker enables using Jenkins as a Pipeline
Trigger, as well as the Run Script stage, which depends on Jenkins as a job
executor.

## Prerequisites

You need a running Jenkins Master at version 1.x - 2.x reachable at a URL
(`$BASEURL`) from whatever provider/environment Spinnaker will be
deployed in.

If Jenkins is secured, you need a username/password
(`$USERNAME`/`$PASSWORD`) pair able to authenticate against Jenkins using
HTTP Basic Auth.

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

1. Apply your changes:

   `hal deploy apply`

## Configure Jenkins and Spinnaker for CSRF protection

> **NOTE:** Jenkins CSRF protection in Igor is only supported for Jenkins 2.x.

To enable Spinnaker and Jenkins to share a crumb to protect against CSRF...

### 1. Configure Halyard to enable the `csrf` flag:

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

### 2. Enable CSRF protection in Jenkins:

a. Under __Manage Jenkins__ > __Configure Global Security__, select __Prevent
Cross Site Request Forgery exploits__.

b. Under __Crumb Algorithm__, select __Default Crumb Issuer__.

![](/setup/ci/jenkins_enable_csrf.png)

## Configure script stage

### Purpose
The [Script stage](/reference/pipeline/stages/#script) lets you run an arbitrary
shell, python, or groovy script on a Jenkins instance as a first class stage in
Spinnaker. This is good for launching an integration/functional test battery
after a bake and deploy stage from a pipeline instead of doing it manually.

### Prerequisites

In order to configure a Script stage, you need:

*   A running Spinnaker instance, with access to configuration files.
*   A running Jenkins instance at `$JENKINS_HOST`, with a user profile set up
    with admin access.

### Configure Jenkins

1.  `ssh` into your Jenkins machine.

2.  Download the [raw job xml config
    file](https://storage.googleapis.com/jenkins-script-stage-config/scriptJobConfig.xml)
    with the command:

    ```bash
    curl -X GET \
        -o "scriptJobConfig.xml" \
        "https://storage.googleapis.com/jenkins-script-stage-config/scriptJobConfig.xml"
    ```

3.  Create the Jenkins job where your script will run. To do this, you need the
    following information:

    *   `$JENKINS_HOST`: your running Jenkins instance.
    *   `$JOB_NAME`: the name of the Jenkins job where your script runs.
    *   `$USER`: your Jenkins username.
    *   `$USER_API_TOKEN`: the API token for your user. You can find this in
        Jenkins in the **Configure** page for your user.

    Then, run the command:

    ```bash
    curl -s -XPOST 'http://$JENKINS_HOST/createItem?name=$JOB_NAME' \
        -u $USER:$USER_API_TOKEN
        --data-binary @scriptJobConfig.xml \
        -H "Content-Type:text/xml"
    ```

4.  Navigate to Jenkins >> the job you just created >> **Configure** and do two
    things:

    1.  Add the GitHub repository containing your scripts.
    2.  Either create a `Spinnaker` node in which Jenkins will run all Script
        jobs, or de-select the **Restrict where this project can be run**
        checkbox.

    At this point, you should be able to manually run the script job in Jenkins
    (including manually adding necessary parameters) and see it succeed.

5.  If your Jenkins master is named anything other than `master` in your
    Spinnaker configuration, you'll need to add the following to
    `orca-local.yml` in order for Spinnaker to find it:

    ```yml
    script:
      master: your-jenkins-master
      job: $JOB_NAME  # from step #3
    ```

You should now be able to use the Script stage in your pipelines.
