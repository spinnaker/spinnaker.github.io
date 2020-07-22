---
layout: single
title:  "Authorization Architecture"
sidebar:
  nav: reference
---

{% include toc %}

## Overview
Fiat works closely with Front50 (apps permissions), Clouddriver (account permissions), and Igor (build services permissions).

### Ingress

Ingress involves the following components: 

- Clouddriver.
- Front50 to query apps and service accounts.
- Gate signs users in with externally provided roles (e.g. OpenID Connect, SAML). These roles are then merged with provider sourced roles (if any), tagged with the `EXTERNAL` source, and cached in Redis.
- Igor gets the list of build systems and roles required to access them.

### Egress

Egress involves the following components: 

- Redis stores computed roles, default permissions, and roles from external systems.
- Clouddriver gets known accounts.
- Front50 gets known apps.

### Scaling

Fiat can be scaled by adding replicas. `fiat.writeMode.enabled` dictates if the Fiat instance will try to sync 
roles. Fiat instances coordinate around locks (in Redis) to ensure that only one instance synchronizes roles at a time.

## Implementation Details

### Roles and Permissions

Fiat uses the following model for user permissions:

- a user ID (= a real one or [`__unrestricted_user__`](#unrestricted-user)  )
- Accounts permission = list of { name + cloudProvider + Permissions)
- Apps permissions = list of { name + permissions }
- Service accounts = list of service accounts the user belongs to
- Roles: list of roles the user has
- build services: list of build services the user has access to

### Sync

Every 30 seconds, Fiat checks if it needs to sync roles. Every 10 minutes (by default), it will sync user ↔ roles. It may mean querying the provider for all the roles of all the users that Fiat knows about (= are cached in Redis).

#### Unrestricted User

- At any point, the unrestricted virtual user should have `UserPermission` in the permission repository (Redis for now) for all accounts, apps, service accounts, build services that have not been restricted (no permission specified).
- The unrestricted user’s permissions is updated on every sync to account for permission changes and for new apps, accounts, etc.
- When returning a user’s permission is returned, it is merged with the unrestricted user. By having the account, app, service account, build service in the `UserPermission` of the user, it is known and the default access for unrestricted app/.. should apply.

#### Note:

During the sync while reading apps permissions from Front50 (in the app definition), Fiat checks if the app has roles defined for `EXECUTE`. If not, Fiat copies the list of roles defined on the app for `fiat.executeFallback` (which can be `READ` or `WRITE`) to the `EXECUTE` permission list. This is done to ensure that at least some roles can execute a pipeline as that role has been introduced recently.

### Verifying Access in Services

A service checks if user `userId` has permission `P`  on resource `R` of type `T` (apps, account, build service). The following steps take place in the service calling Fiat. The response is detailed thereafter.

If Fiat is not enabled → Yes
If Fiat is enabled → query Fiat with `userId`:

- Check the local cache first (which expires after `services.fiat.cache.expiresAfterWriteSeconds` and defaults to 20)
- If the request fails, retry will back off.  If it keeps failing:
    - if `services.fiat.legacyFallback = true`:
        - If `T == account`: if the account has at least one `WRITE` permission, Yes (TO BE CONFIRMED), otherwise No
        - if `T == app`: Yes (note: via `allowAccessToUnknownApplications`)
        - if `T == buildService`: Yes
    - else reject
- if the request succeeds, permissions are returned by Fiat:
    - If the user is admin → Yes
    - If `T = account` : check that the permission has been returned by Fiat (= permission `P` is found for `R` in map `T`)
    - if `T = app`:
        - if the user has access to the account with the right permission → Yes
        - Else if the user does not have any permission set for this app and  `permission.allowAccessToUnknownApplications == true` → Yes
        - Else reject
    - if `T = buildService`: check that the user has the right permission for the build service
    
    
### Permissions returned by Fiat

Fiat can be asked to return all permissions to a user `U`. These permissions are stored in Redis under the following keys `spinnaker:fiat:permissions:<user ID>:<resource type>` and store a hash with the following info:

- `key` = name of the resource (e.g. name of the app)
- `value` = `{"name": <name repeated>, "permissions": { <Permission>: [list of roles] } }`

#### Example


    HGETALL spinnaker:fiat:permissions:__unrestricted_user__:applications
    1) "app1" 
    2) "{\n  \"name\" : \"app1\",\n  \"permissions\" : { }\n}"
    3) "ncecs"
    4) "{\n  \"name\" : \"app2\",\n  \"permissions\" : { }\n}"
    5) "cam"
    6) "{\n  \"name\" : \"app3\",\n  \"permissions\" : { }\n}"

### Permissions Returned

Fiat will look up permissions in Redis:

- If the user is not known to Fiat (edge case, should not happen under normal circumstances but will happen if you try to `curl` to Fiat directly) or if there was a communication issue/bug with Redis
    -  if `fiat.defaultToUnrestrictedUser == true`: treat as the unrestricted user
    - else 404 → the request has failed
- Merge the permission of the user with the unrestricted user’s permission
    - As a reminder: the unrestricted user only has permissions for resources not constrained.
- Set `permission.isAdmin` to true if the user has been defined as an admin
    - This is true when the user has a role defined in `fiat.admin.roles` 
- Set `permission.allowAccessToUnknownApplications` to the setting `fiat.allowAccessToUnknownApplications`

### Summary of available options in a local config file

| Setting | Effect | Default |
| --- | --- | --- |
| `auth.group-membership.file` | Path of the file containing roles and users  | |
| `auth.group-membership.service`         | Chooses the type of role provider:<br><br>- `file`: File based role provider<br>- `github`:  GitHub team role provider<br>- `google`: Google Groups role provider<br>- `ldap`: LDAP provider                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |         |
| `auth.group-membership.github.*`        | Settings for the Github provider<br><br>- `baseUrl`<br>- `accessToken`<br>- `organization`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |         |
| `auth.group-membership.google.*`        | Settings for the Google provider<br><br>- `credentialPath`: Path to the credentials to auth w/ Google<br>- `adminUsername`: Email of the Google Apps admin the service account is acting on behalf of<br>- `domain`: Domain name in Google Apps<br>- `roleSources`: Name of the attributes to map the roles from (can just be `NAME` or `EMAIL`) - defaults to `NAME`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |         |
| `auth.group-membership.ldap.*`          | Settings for LDAP provider - DN = Distinguished Name - see LDAP provider above for usage<br><br>- `url`: URL of the LDAP server<br>- `managerDN`:  DN of the user Fiat will impersonate to query LDAP<br>- `managerPassword`: Password of the user above<br>- `groupSearchBase`:<br>- `userSearchBase`:<br>- `userSearchFilter`:<br>- `groupRoleAttributes` (`cn`):<br>- `groupSearchFilter` (`(uniqueMember={0})`):<br>- `userDnPattern` (`uid={0},ou=users`):                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |         |
| `fiat.getAllEnabled`                    | Enables the `/authorize` endpoint to return all permissions for all users                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `false` |
| `fiat.defaultToUnrestrictedUser`        | If true and the user is not defined in Fiat (or Redis operations fail), gives all permissions to the user. This should be an edge case as under normal circumstances all users that have signed in should be known to Fiat.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `false` |
| `fiat.allowAccessToUnknownApplications` | If true, this will give a user that has not been given a permission for a specific app any access (read, write, exec) to that app. This is different from an app not having any permissions defined and defaulting to all permissions for all.<br><br>Here, you can have an app with some permissions (role 1 = READ, role 2 = WRITE) but if user is role 3, they would be unable to gain access to the app. A user with role 1 would be limited to READ.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `false` |
| `fiat.executeFallback`                  | For apps not created with `EXECUTE` permissions explicitly, `EXECUTE` permissions is given to users with `READ` permissions by default. You can change that by setting this to `WRITE` (only users with `WRITE` would be able to execute the pipeline.)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `READ`  |
| `fiat.writeMode.*`                      | Controlling how Fiat writes to its cache:<br><br>- `enabled` (true)<br>- `syncDelayMs` (600000 = 10 minutes): how much effective time between each sync<br>- `retryIntervalMs` (10000 = 10s): if sync fails, how much time to wait before retrying                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |         |
| `fiat.admin.roles`                      | List of roles that grant admin access. Roles listed here are transformed to lower case.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `[]`    |
| `fiat.role.orMode`                      | If true, a user has access to a service account if they have any role defined in the service account roles. <br>By default, it is false and the user needs to have all roles in the service accounts.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `false` |
| `services.fiat.*`                       | These properties are listed here but actually live in services that use Fiat, they dictate how to use Fiat:<br><br><br>- `refreshable` (true): If true, the service will check every 30s the status of the properties defined here<br>- `baseUrl`: Fiat’s base URL<br>- `enabled` (false): Is Fiat enabled? <br>- `legacyFallback` (false): On a permission retrieval failure, should the user be granted access?<br>- `connectTimeoutMs` (none): If set, overrides the OkHTTP connection’s connection timeout when connecting to Fiat<br>- `readTimeoutMs` (none): If set, overrides the OkHTTP connection’s read timeout when querying Fiat<br>- `cache.expiresAfterWriteSeconds` (20): Expiration of local service cache of Fiat properties <br>- `cache.maxEntries` (1000): Max number of items in the local service cache<br>- `retry.maxBackoffMillis` (10000): On Fiat request failure, max back off<br>- `retry.initialBackoffMillis` (500): Initial backoff on Fiat request failure<br>- `retry.retryMultiplier` (1.5): Backoff multiplier |         |
