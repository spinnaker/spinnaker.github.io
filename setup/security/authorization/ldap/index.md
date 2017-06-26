---
layout: single
title:  "LDAP"
sidebar:
  nav: setup
---

{% include toc %}

Groups from an LDAP directory use a manager's username/password to bind and search for a user's 
groups.

## User DNs

Sample configuration:
```yaml
auth:
  groupMembership:
    service: ldap
    ldap:
      url: ldaps://ldap.mydomain.net:636/dc=mydomain,dc=net
      managerDn: uid=admin,ou=system
      managerPassword: batman
      userDnPattern: uid={0},ou=users
      groupSearchBase: ou=groups
      groupSearchFilter: (uniqueMember={0})
      groupRoleAttributes: cn
```

When searching for a user's groups, the `userDnPattern` is used to construct the user's full 
distinguished name (DN). In the case above, the user `joe` would have a full DN of 
`uid=joe,ou=users,dc=mydomain,dc=net`. 

The search would be rooted at `ou=groups,dc=mydomain,dc=net`, looking for directory entries that 
include the attribute `uniqueMember=uid=joe,ou=users,dc=mydomain,dc=net`, which is the structure 
for the `groupOfUniqueNames` group standard.

The `groupRoleAttribute` is how the group/role name is extracted. For example, all entries that 
pass the filter will then have the `cn` (common name) attribute returned.



## Configure with Halyard

TODO: Update these details when halyard supports LDAP.

In the mean time, put the above configuration in `~/.hal/$DEPLOYMENT/profiles/fiat-local.yml`, creating it if needed.


## Troubleshooting
