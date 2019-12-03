---
layout: single
title:  "Fiat Permissions"
sidebar:
  nav: setup
---

{% include toc %}

Unless you have set `fiat.legacyFallback` to `true` (defaults to `false`) you will need to configure 
Igor CI services with Fiat `READ` and `WRITE` permissions.

Here is a Jenkins example:

```yaml
jenkins:
  enabled: true
  masters:
  - name: <jenkins master name>
    address: http://<jenkins ip>/jenkins
    username: <jenkins admin user>
    password: <admin password>
    csrf: true
    permissions:
      READ:
      - foo
      - bar
      WRITE:
      - bar
```

In the example above, users with the `foo` or `bar` roles will be able to see the build master and 
use it as a trigger, and users with the `bar` role will additionally be able to trigger builds. 

Users without these roles will not see the build master in Deck at all.
