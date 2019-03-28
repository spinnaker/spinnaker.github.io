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

## Directory Structure

LDAP directories are generally organized by first defining a "root" distinguished name (DN). User
DNs are constructed by combining this root DN with a user DN pattern.

For example, if your root DN is `dc=my-organization,dc=com` and your user pattern is
`uid={0},ou=users`, and user with the id `joe` would have a full, unique DN of
`uid=joe,ou=users,dc=my-organization,dc=com`.

When `joe` is trying to login, this full user DN is constructed and passed to the LDAP server with
his password. The password is hashed on the server and compared to its own hashed version. If
successful, the bind is successful and a session is established.

> We highly suggest the use of SSL for the LDAP connection (over `ldaps`). Otherwise,
**user passwords are passed in clear text over the wire.**

## Configure LDAP using Halyard

Use `hal config` to enable and configure LDAP. Here's an example:

`hal config security authn ldap edit --user-dn-pattern="uid={0},ou=users" --url=ldaps://ldap.my-organization.com:10636/dc=my-organization,dc=com`

`hal config security authn ldap enable`

You can also use `ldap.userSearchBase` and `ldap.userSearchFilter` if the simpler
`ldap.userDnPattern` does not match what your organization uses for `userDn`s. We don't explore this
use case here, but you can read up more on LDAP search filters
[here](https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html){:target="\_blank"}.


## Workflow

<div class="mermaid">
    sequenceDiagram

    participant Deck
    participant Gate
    participant LDAPServer

    Deck->>+Gate: GET /something/protected
    Gate->>-Deck: HTTP 302 to /login
    Deck->>+Gate: GET /login
    Gate->>-Deck: Returns login page    
</div>

1. User attempts to access a protected resource.

1. Gate redirects to a basic `/login` page. This page is hosted on the Gate server.

    <div class="mermaid">
        sequenceDiagram

        participant Deck
        participant Gate
        participant LDAPServer

        Deck->>+Gate: User sends credentials
        Gate->>+LDAPServer: Gate attempts to bind using user credentials
        Note right of LDAPServer: Server compares password hashes
        LDAPServer->>-Gate: Session established
        Gate->>-Deck: HTTP 302 to /something/protected
    </div>

1. User enters credentials

1. Gate attempts to establish a session (preferably over SSL) with the LDAP server, sending the
username and password

1. The LDAP server hashes the user's password and compares it to its local copy. If successful,
the session is established. Otherwise, a "Bad Credentials" exception is thrown.

1. Gate redirects the user to the originally requested URL.

{% include mermaid %}

## Next steps

Now that you've authenticated the user, proceed to setting up their [authorization](/setup/security/authorization/).

## Troubleshooting

* Review the general [authentication workflow](/setup/security/authentication#workflow).

* Use an [incognito window](/setup/security/authentication#incognito-mode).

* I'm getting the "Bad Credentials" exception mentioned above, but my username and password is
correct!

    Ensure that the fully qualified user DN is correct. Confirm with your LDAP administrator how
    your organization's LDAP directory is structured.
