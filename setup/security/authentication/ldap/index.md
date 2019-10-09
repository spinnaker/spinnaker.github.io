---
title:  "LDAP"
sidebar:
  nav: setup
---

{% include toc %}

Lightweight Directory Access Protocol (LDAP) is a standard way many organizations maintain user
credentials and group memberships. Spinnaker uses the standard "*bind*" approach for user
authentication. This is a fancy way of saying that Gate uses your username and password to login
to the LDAP server, and if the connection is successful, you're considered authenticated.


### Notes
*  Make sure you’re using Halyard greater than 1.6.0 as that adds the ability to set the manager user/password settings. 
You can use a prior version, but you will need to use a gate-local.yml to define the properties vs. being able
to use halyard.

* We highly suggest the use of SSL for the LDAP connection (over `ldaps`). Otherwise, **user passwords are passed in 
clear text over the wire.**

* Ports commonly used/referenced/how:
    *  636 - ldaps port. (aka ldap with SSL)
    *  389 - ldap 
    *  3268 - AD Global Directory NON ssl port
    *  3269 - AD Global Directory SSL port

From a protocol perspective, ldap://host/whatever implies port 389 by defualt.  ldaps://host/whatever will use 636 by 
default.

## Directory Structure

LDAP directories are generally organized by first defining a "root" distinguished name (DN). User
DNs are constructed by combining this root DN with a user DN pattern.

For example, if your root DN is `dc=my-organization,dc=com` and your user pattern is
`uid={0},ou=users`, and user with the id `joe` would have a full, unique DN of
`uid=joe,ou=users,dc=my-organization,dc=com`.

When `joe` is trying to login, this full user DN is constructed and passed to the LDAP server with
his password. The password is hashed on the server and compared to its own hashed version. If
successful, the bind (aka connection) is successful and a Gate creates a session.


## Configure LDAP using Halyard

Use `hal config` to enable and configure LDAP. Here's an example:

```bash

hal config security authn ldap edit --user-dn-pattern="uid={0},ou=users" \ 
       --url=ldaps://ldap.my-organization.com:636/dc=my-organization,dc=com

hal config security authn ldap enable
```

You can also use `user-search-base` (optional) and `user-search-filter` if the simpler
`user-dn-pattern` does not match what your organization uses for `userDn`s. We don't explore this
use case here, but you can read up more on LDAP search filters
[here](https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html){:target="\_blank"}.


## Active Directory

1. It is recommend to NOT use the userDnPattern for AD. Per an issue ticket: “userDnPattern should remain unset - 
AD groups store user DNs in the memberOf attribute; finding DNs from sAMAccountNames is easily doable 
but not with a simple, single-level pattern. The DN contains the the CN, and that can’t really be constructed 
without sub searches. userSearchFilter takes precedence if there’s no user-dn-pattern set.”

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

Last, here’s the halyard commands to configure these:
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

* Use an [incognito window](/setup/security/authentication#incognito-mode).

* I'm getting the "Bad Credentials" exception mentioned above, but my username and password is
correct!

    Ensure that the fully qualified user DN is correct. Confirm with your LDAP administrator how
    your organization's LDAP directory is structured.
