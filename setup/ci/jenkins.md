---
layout: single
title:  "Jenkins"
sidebar:
  nav: setup
redirect_from: /docs/jenkins-script-execution-stage
---

Setting up [Jenkins](https://jenkins.io/) as a Continuous Integration (CI)
system within Spinnaker enables using Jenkins as a Pipeline Trigger, as well as
the Run Script stage, which depends on Jenkins as a job executor.

## Prerequisites

You need a running Jenkins Master at version 1.x - 2.x reachable at a URL
(`$BASEURL`) from whatever provider/environment Spinnaker will be
deployed in.

If Jenkins is secured, you need a username/password
(`$USERNAME`/`$PASSWORD`) pair able to authenticate against Jenkins using
HTTP Basic Auth.

## Add your Jenkins master

First, make sure that your Jenkins master is enabled:

```bash
hal config ci jenkins enable
```

Next, we will add Jenkins master named `my-jenkins-master` (an arbitrary,
human-readable name), to your list of Jenkins masters:

```bash
echo $PASSWORD | hal config ci jenkins master add my-jenkins-master \
    --address $BASEURL \
    --username $USERNAME \
    --password # password will be read from STDIN to avoid appearing
               # in your .bash_history
```

> *Note*: If you use the [GitHub OAuth plugin](https://wiki.jenkins.io/display/JENKINS/GitHub+OAuth+Plugin)
> for authentication into Jenkins, you can use the GitHub $USERNAME, and use the
> OAuth token as the $PASSWORD.

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

### 2. Enable CSRF protection in Jenkins:

a. Under __Manage Jenkins__ > __Configure Global Security__, select __Prevent
Cross Site Request Forgery exploits__.

b. Under __Crumb Algorithm__, select __Default Crumb Issuer__.

![](/setup/ci/jenkins_enable_csrf.png)

## Jenkins script execution stage

### Purpose
The script stage lets a Spinnaker user run an arbitrary shell, python, or
groovy script on a Jenkins instance as a first class stage in Spinnaker.
This is good for launching an integration/functional test battery
after a bake and deploy stage from a pipeline instead of doing it manually.

### Assumptions
Here are a few assumptions we make in the following directions:

You have a running Spinnaker instance, with access to configuration files.

You have a running Jenkins instance at `<jenkins_host>`, with a user profile set up with admin access.

### Configuring Jenkins
`ssh` into your Jenkins machine.

`wget` or `curl` the [raw job xml config file](https://storage.googleapis.com/jenkins-script-stage-config/scriptJobConfig.xml).

To create the Jenkins job, run:

```
curl -X POST -H "Content-Type: application/xml" -d @scriptJobConfig.xml \
"http://<username>:<user_api_token>@<jenkins_host>/jenkins/createItem?name=<JOB_Name>"
```

where `<JOB_NAME>` is the name of the Jenkins job you create, e.g. "runSpinnakerScript"
and `<user_api_token>` is the API token for your user, located at "/user/<username>/configure".

In the job config in the Jenkins UI, set the GitHub repository containing your scripts as
well as the git credentials.

In the UI, go to `"Manage Jenkins"` >> `"Configure System"` and set your git `user.name` and `user.email`.

At this point, you should be able to manually run the script job in Jenkins
(with parameters) and see it succeed.

### Configuring Spinnaker
Enable Igor.

In spinnaker-local.yml, set:

```
jenkins.enabled = true
jenkins.masters[0].name = <jenkins_name>
jenkins.masters[0].address = http://<jenkins_host>/jenkins Note that "/jenkins" might not be the base path, it depends on how Jenkins is configured.
jenkins.masters[0].username = <username>
jenkins.masters[0].password = <user_api_token>
```

In orca.yml, add:

```
script:
  master: <jenkins_name> # name of Jenkins master in Spinnaker
  job: <JOB_NAME> # from Jenkins job configuration
```

Restart Orca and Igor if you didn't have a Jenkins master
configured in Spinnaker.

### Summary

You should now be able to add a stage called "Script" to your pipelines,
where you can specify:

Repository Url: git repository housing your scripts.
Script path: path from the root of your git repository to your script's
directory.
Command: name of the script with arguments to run.
Among other environment parameters (e.g. image, account, etc).

The current version of the script stage is a bit rudimentary, but we'll
soon have support for a separate "job" stage that will be much more robust and encapsulate
the same behavior as the script stage. The script stage is a temporary
solution for the time being.
