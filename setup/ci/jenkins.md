---
layout: single
title:  "Jenkins"
sidebar:
  nav: setup
---

{% include toc %}

Setting up [Jenkins](https://jenkins.io/) as a Continuous Integration (CI)
system within Spinnaker enables using Jenkins as a Pipeline Trigger, as well as
the Run Script stage, which depends on Jenkins as a job executor.

## Prerequisites

You need a running Jenkins Master at version 1.x - 2.x reachable at a URL
(`$BASEURL`) from whatever provider/environment Spinnaker will be
deployed in. If Jenkins is secured, you need a username/password
(`$USERNAME`/`$PASSWORD`) pair able to authenticate against Jenkins using
HTTP Basic Auth.

## Adding Your Jenkins Master

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
