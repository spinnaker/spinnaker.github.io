---
layout: single
title:  "LDAP"
sidebar:
  nav: setup
---

{% include toc %}


Please note that LDAP is flexible enough to offer lots of other options and configuration possibilities.  Spinnaker
uses the Spring Security libraries, which solve a number of challenges.  


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

## How Fiat determines group membership
The LDAP provider works by querying the LDAP server utilizing a user as set by the 
[manager-dn and managerPassword](/reference/halyard/commands/#hal-config-security-authz-ldap-edit) and making a 
query that uses the logged-in user's username to filter results. 

Fiat will use the "bound" account to do the following:
- Make a query using a base of `group-search-base`. **THIS IS A REQUIRED FIELD.** If not set, no roles get queried.
- That query uses `group-search-filter` to find the results.  
- This uses a parameter of the user's full DN as a filter.  This means the ONLY groups shown are those which the user is a member.
- For the groups retrieved, get the role names.  This uses the `group-role-attributes` attribute (defaults to `cn`).

## How to determine the "Full DN" 

- Extract the Root DN from the `url` (`ldaps://my.server/a/b/c` → `a/b/c`)
    >If `com.netflix.spinnaker.fiat.roles.ldap.LdapUserRolesProvider` log level is at debug, you should 
    see `Root DN: <the actual root DN extracted>`
- If `user-search-filter` is provided then:
    - Search LDAP:
        - For `user-search-base`
        - Using `user-search-filter` aka `(uid={0})`
    - Return root DN computed + found user DN
- ELSE when `user-search-filter` is not provided:
    - Make user DN using `user-dn-pattern`
    - Return root DN computed + user DN

You must provide either a search filter or a DN pattern.  In the case below, the user `joe` would have a full DN of
`uid=joe,ou=users,dc=mydomain,dc=net`.

The search would be rooted at `ou=groups,dc=mydomain,dc=net`, looking for directory entries that
include the attribute `uniqueMember=uid=joe,ou=users,dc=mydomain,dc=net`, which is the structure
for the `groupOfUniqueNames` group standard.

The `group-role-attribute` is how the group/role name is extracted. For example, all entries that
pass the filter will then have the `cn` (common name) attribute returned. 

> IF you want to use a username instead of a user DN for group membership, you can specify `{1}` instead of `{0}` for 
the `group-search-filter` parameter.  

## Source code

To see the internals (can be useful for debugging):
* Fiat: [LdapUserRolesProvider](https://github.com/spinnaker/fiat/blob/master/fiat-ldap/src/main/java/com/netflix/spinnaker/fiat/roles/ldap/LdapUserRolesProvider.java)
* Spring Auth Provider: [LdapAuthenticationProviderConfigurer](https://github.com/spring-projects/spring-security/blob/master/config/src/main/java/org/springframework/security/config/annotation/authentication/configurers/ldap/LdapAuthenticationProviderConfigurer.java)
* Gate: [LdapSsoConfig](https://github.com/spinnaker/gate/blob/master/gate-ldap/src/main/groovy/com/netflix/spinnaker/gate/security/ldap/LdapSsoConfig.groovy)

## Next steps...

* Read through [Authorization Overview](/setup/security/authorization/)
* Read through [LDAP Authorization](/setup/security/authorization/ldap/)


