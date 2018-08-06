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

When searching for a user's groups, a `userDnPattern` is used to construct the user's full
distinguished name (DN). In the case below, the user `joe` would have a full DN of
`uid=joe,ou=users,dc=mydomain,dc=net`.

The search would be rooted at `ou=groups,dc=mydomain,dc=net`, looking for directory entries that
include the attribute `uniqueMember=uid=joe,ou=users,dc=mydomain,dc=net`, which is the structure
for the `groupOfUniqueNames` group standard.

The `groupRoleAttribute` is how the group/role name is extracted. For example, all entries that
pass the filter will then have the `cn` (common name) attribute returned.



## Configure with Halyard

With the ldap manager credentials and search patterns in hand, use Halyard to configure Fiat:

```bash
hal config security authz ldap edit \
    --url ldaps://ldap.mydomain.net:636/dc=mydomain,dc=net \
    --manager-dn uid=admin,ou=system \
    --manager-password \
    --user-dn-pattern uid={0},ou=users \
    --group-search-base ou=groups \
    --group-search-filter "(uniqueMember={0})" \
    --group-role-attributes cn
      
 hal config security authz edit --type ldap
 hal config security authz enable
```
