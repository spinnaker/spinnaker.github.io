---
layout: single
title:  "Configuring the Script stage"
sidebar:
  nav: setup
---

{% include toc %}

## Purpose
The [Script stage](/reference/pipeline/stages/#script) lets you run an arbitrary
shell, Python, or Groovy script on a Jenkins instance as a first class stage in
Spinnaker. For example, you can use it to launch a test suite from a pipeline
instead of doing it manually. In order to be able to use the Script stage, you
need to configure

## Prerequisites

In order to configure a Script stage, you need:

*   A running Jenkins instance at `$JENKINS_HOST`, with a user profile set up
    with admin access
*   A running Spinnaker instance, with access to configuration files, and in
    which you have [set up Jenkins on Spinnaker](/setup/ci/jenkins/)

## Configure Jenkins

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

    At this point, you can manually run the script job in Jenkins (including
    manually adding necessary parameters) and see it succeed.

5.  If your Jenkins master is named anything other than `master` in your
    Spinnaker configuration, you'll need to add the following to
    `orca-local.yml` in order for Spinnaker to find it:

    ```yml
    script:
      master: your-jenkins-master
      job: $JOB_NAME  # from step #3
    ```

You can now use the Script stage in your pipelines.
