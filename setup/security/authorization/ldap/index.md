---
layout: single
title:  "LDAP"
sidebar:
  nav: setup
---

{% include toc %}


Please note that LDAP is flexible enough to offer lots of other options and configuration possibilities.  Spinnaker
uses the Spring Security libraries, which solves a number of challenges.  


## Configure with Halyard

With the LDAP manager credentials and search patterns in hand, use Halyard to configure Fiat:

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
The above is a sample.  See below for more information.

## How does Fiat determine group membership
The LDAP provider works by querying the LDAP server utilizing a user as set by the 
[manager-dn and managerPassword](/reference/halyard/commands/#hal-config-security-authz-ldap-edit) and making a 
query. If a manager is NOT set, Spinnaker falls back to validating group membership using the login user's credentials.  

Fiat will use the "bound" account to do the following:
- Make a query for `group-search-base`. **THIS IS A REQUIRED FIELD.**  If not set, no roles get queried.
- Filter the obtained groups with `group-search-filter`.  This uses the group-role-attribute (`cn=X`) field on the query to find role names. 
- For the groups associated with the user’s full DN = `the user id of the user`
- For the groups retrieved, the roles will be the `group-role-attributes` attributes.

## How to determine the "User DN" 

- Extract the Root DN from the `url` (`ldaps://my.server/a/b/c` → `a/b/c`)
    - If `com.netflix.spinnaker.fiat.roles.ldap.LdapUserRolesProvider` log level is at debug, you should 
    see `Root DN: <the actual root DN extracted>`
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

NOTE IF you want to use a username instead of a user dn for group membership, you can specificy `{1}` instead of `{0}` for 
the `group-search-filter` parameter.  
