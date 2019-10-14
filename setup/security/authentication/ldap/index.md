---
title:  "LDAP"
sidebar:
  nav: setup
---

{% include toc %}

Lightweight Directory Access Protocol (LDAP) is a standard way many organizations maintain user
credentials and group memberships. Spinnaker uses the standard "*bind*" approach for user
authentication. This is a fancy way of saying that Gate uses your username and password to login
to the LDAP server, and if the connection is successful, you're considered authenticated.  Note that there is a
fair bit of crossover with authorization.  


### Notes

*  Make sure you’re using Halyard 1.20 or later as that adds the ability to set the manager user/password settings. 
You can use a prior version, but you will need to use a `gate-local.yml` to define the manager properties instead of being able
to use Halyard.

* If the manager Domain Name (DN) is NOT set, all searches attempt to use the user currently logging in.  You'll often see errors
in the log files tied to "bind failures" and LDAP error codes.

* Escaping things like spaces is handled by the library.  You do NOT need to use LDAP escape codes to handle spaces.  

* We highly suggest the use of SSL for the LDAP connection (`ldaps://...`). Otherwise, **user passwords are passed in 
clear text over the wire.**

* Ports commonly used or referenced:
    *  636 - LDAP with SSL (`ldaps`)
    *  389 - LDAP 
    *  3268 - Active Directory (AD) Global Directory NON ssl port
    *  3269 - AD Global Directory SSL port

When a port is not specified, `ldap://host/whatever` implies port 389 by default.  `ldaps://host/whatever` uses port 636 by 
default.

## How to determine the "User DN" 

- Extract the Root DN from the `url` (`ldaps://my.server/a/b/c` → `a/b/c`)
    - If `com.netflix.spinnaker.fiat.roles.ldap.LdapUserRolesProvider` log level is at debug, you should 
    see `Root DN: <the actual root DN extracted>`
- If `--user-search-filter` is provided:
    - Search LDAP:
        - Search in  `--user-search-base` OR the root (would be `a/b/c` in this example) if user-search-base is not set.
        - Filtered by `--user-search-filter="(d={0})"` where `uid=<the username as typed in>`, such as `joe`.
        - Start at the rootDn and use sub tree searches
    - Return root DN computed + the found user DN
- If `user-search-filter` is not provided:
    - Calculate the user DN using `user-dn-pattern`.  In the case below, the user `joe` would have a full DN of 
    `uid=joe,ou=users,dc=mydomain,dc=net`.
    - Return root DN computed + user DN
    

For example, given the following parameters:

* Root DN is `dc=my-organization,dc=com` 
* `user-dn-pattern` is `uid={0},ou=users`
* User with the id `joe` 

The full, unique DN would be `uid=joe,ou=users,dc=my-organization,dc=com`.

When `joe` is trying to login, this full user DN is constructed and passed to the LDAP server with
his password. The password is hashed on the server and compared to its own hashed version. If
successful, the bind (aka connection) is successful and Gate creates a session.

## Testing with ldapsearch

In the above example, you could test with:

```bash
//Search using manager dn, manager password on url with base of "X"
# When: --user-search-filter=(uid={0}) --user-search-base=DC=USERS,OU=Y,O=io 
ldapsearch -D "MANAGER_DN" -w 'MANAGER_PASSWORD' -H ldaps://1.2.3.4 -x -b "DC=USERS,OU=Y,O=io" "(UID=USERNAME)"
```
Without a user-search-base
```bash
//Search usering manager dn, manager password on url with base of "X"
# When: --user-search-filter=(uid={0}) 
ldapsearch -D "MANAGER_DN" -w 'MANAGER_PASSWORD' -H ldaps://1.2.3.4 -x   "(UID=USERNAME})"
```
Without a user-search-filter
```bash
//Search usering manager dn, manager password on url with base of "X"
# When: --user-dn-pattern=(uid={0},ou=users) 
ldapsearch -D "MANAGER_DN" -w 'MANAGER_PASSWORD' -H ldaps://1.2.3.4/OU=Y,O=io -x "(CN=USERNAME,OU=users,OU=Y,O=IO))"
```

## Configure LDAP Using Halyard

You can use `hal config` to enable and configure LDAP. Here's an example:

```bash

hal config security authn ldap edit --user-dn-pattern="uid={0},ou=users" \ 
       --url=ldaps://ldap.my-organization.com:636/dc=my-organization,dc=com

hal config security authn ldap enable
```

You can also use `--user-search-base` (optional) and `--user-search-filter` if the simpler
`--user-dn-pattern` does not match what your organization uses for `userDn`. We don't explore this
use case here, but you can read up more on LDAP search filters
[here](https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html){:target="\_blank"}.


## Active Directory

1. We recommend NOT using the `--user-dn-pattern` argument for AD. The following issue has been reported in an issue ticket:
 
    “userDnPattern should remain unset - AD groups store user DNs in the memberOf attribute; finding DNs from sAMAccountNames is easily doable but not with a simple, single-level pattern. The DN contains the the CN, and that can’t really be constructed without sub searches. userSearchFilter takes precedence if there’s no user-dn-pattern set.”

1. Here's the raw settings that will eventually be there in gate as an example.
```
ldap:
  enabled: true
  url:  ldaps://somethingsomething:686/ou=users,ou=company,o=com
  userSearchFilter: (&(objectClass=user)(sAMAccountName={0}))
  managerDn: CN=SVC_LDAP_USER_RO,OU=service-users,OU=company,O=com
  managerPassword: super-secret-password
```
The managerUser will then find a user in your ou=users,ou=company,o=com directory via a subtree search. You 
should be able to set the user-search-base parameter vs. including it on the URL to have it specified separately.

Last, here are the Halyard commands to configure these:
```bash
hal config security authn ldap enable
hal config security authn ldap edit \
  --manager-dn 'CN=blah,OU=blah,OU=blah,O=blah' \
  --user-search-filter '(&(objectClass=user)(sAMAccountName={0}))' \
  --url ldaps://blah:686/searchbase
## This one will prompt you for the password don't set it on the command
hal config security authn ldap edit --manager-password
```


## Next steps

Now that you've authenticated the user, proceed to setting up their [authorization](/setup/security/authorization/).

## Troubleshooting

* Review the general [authentication workflow](/setup/security/authentication#workflow).

* Use an [Incognito window](/setup/security/authentication#incognito-mode). Close all Incognito windows between attempts.

* I'm getting the "Bad Credentials" exception mentioned above, but my username and password is
correct!

    Ensure that the fully qualified user DN is correct. Confirm with your LDAP administrator how
    your organization's LDAP directory is structured.
