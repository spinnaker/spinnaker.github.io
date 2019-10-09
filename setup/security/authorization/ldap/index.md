---
layout: single
title:  "LDAP"
sidebar:
  nav: setup
---

{% include toc %}


Please note that LDAP is flexible enough to offer lots of other options and configuration possibilities.  Note, where 
possible, we'll use the halyard parameter vs the file parameter.  Certain settings can be set only directly not with
halyard.

## How does Fiat determine group membership
The LDAP provider works by querying the LDAP server utilizing a user as set by the 
[manager-dn and managerPassword](/reference/halyard/commands/#hal-config-security-authz-ldap-edit) and making a 
query. If a manager is NOT set, Spinnaker will fallback to attempting to validate group membership using the logging 
in users credentials.  

Fiat will use the "bound" account to do the following:
- Make a query for `group-search-base`
- Filter the obtained groups with `group-search-filter`
- For the groups associated with the user’s full DN = `the user id of the user`
- For the groups retrieved, the roles will be the `group-role-attributes` attributes.

## How to determine the "User DN" 

- Extract the Root DN from the `url` (`ldaps://my.server/a/b/c` → `a/b/c`)
    - If `com.netflix.spinnaker.fiat.roles.ldap.LdapUserRolesProvider` log level is at debug, you should 
    see `Root DN: <the actual root DN extracted`
- If `user-search-filter` is provided:
    - Search LDAP:
        - For `user-search-base`
        - Filtered by `user-search-filter` = `the user id`
    - Return root DN computed + found user DN
- If `user-search-filter` is not provided:
    - Make user DN using `user-dn-pattern`
    - Return root DN computed + user DN
    
When searching for a user's groups, a `user-dn-pattern` is used to construct the user's full
distinguished name (DN). In the case below, the user `joe` would have a full DN of
`uid=joe,ou=users,dc=mydomain,dc=net`.

The search would be rooted at `ou=groups,dc=mydomain,dc=net`, looking for directory entries that
include the attribute `uniqueMember=uid=joe,ou=users,dc=mydomain,dc=net`, which is the structure
for the `groupOfUniqueNames` group standard.

The `group-role-attribute` is how the group/role name is extracted. For example, all entries that
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

