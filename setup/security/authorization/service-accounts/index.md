---
layout: single
title:  "Service Accounts"
sidebar:
  nav: setup
---

{% include toc %}

Fiat Service Accounts enable the ability for automatically triggered pipelines to modify 
resources in protected accounts or applications. Practically speaking, this means that a git 
commit could trigger a Jenkins build that could kick off a pipeline to deploy the newly built 
image in your access-controlled QA environment.


## Creating Service Accounts

Service accounts are persistent and configuration merely consists of giving it a name and a set 
of roles. Therefore, Front50 is the most logical place to configure a service account. There is 
no UI for creating service accounts at the moment. 

TODO: Update when Halyard supports service accounts

```bash
FRONT50=http://front50.url:8080

curl -X POST \
  -H "Content-type: application/json" \
  -d '{ "name": "myApp-svc-account", "memberOf": ["myApp-prod","myApp-qa"] }' \
  $FRONT50/serviceAccounts
```

A Fiat sync may be necessary for all affected users to pick up the changes:

```bash
FIAT=http://fiat.url:7003

curl -X POST $FIAT/roles/sync
```

Confirm the new service account has permissions to the resources you think it should by querying 
Fiat:

```bash
$ curl $FIAT/authorize/myApp-svc-account
```

## Using Service Accounts
With Fiat enabled, you should now see a “Run As User” option in your Trigger configuration. This
list contains all of the service accounts you currently have access to.

![run as user from pipeline config in UI](run-as-user.png)

Upon saving this pipeline, two authorization checks occur:
1. Does this user have access to this service account? (If using the UI, this should always be 
the case.)
1. Does this service account have access to this application?

At pipeline runtime, standard authorization checks against the account and application occur 
just as if it were a human user.


## Troubleshooting
