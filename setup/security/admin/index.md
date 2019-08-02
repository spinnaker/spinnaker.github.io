---
layout: single
title:  "Administrator functionality"
sidebar:
  nav: setup
---

{% include toc %}

## Introduction
In Spinnaker, it is possible to define that users belonging to a certain role are considered "Administrators". This virtually removes all READ/WRITE restrictions to accounts and applications for these users.

{% include
   warning
   content="This feature gives God Mode like capabilities to the users who are admins. Proceed with caution."
%}

## Enable and Configure Admin functionality

### Halyard
TBD

### Manually add configuration in Fiat

In the Fiat config file, add the following:

```yaml
fiat:
  admin:
    roles:
      - devops-admin
```

> For installations managed by Halyard, the file should be located in the following path
`~/.hal/$DEPLOYMENT/profiles/fiat-local.yml` and remember to `hal deploy apply` after the change
