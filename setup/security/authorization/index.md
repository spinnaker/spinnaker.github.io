---
layout: single
title:  "Authorization (RBAC)"
sidebar:
  nav: setup
redirect_from: /docs/fiat-setup
---

{% include toc %}

### Overview

Fiat (Fix it Again Travis) is the authorization (authz) microservice of Spinnaker. It can grant access to users 
to execute pipelines, view infrastructure, etc. It is disabled by default. Much like authentication, Spinnaker allows for a 
variety of pluggable authorization mechanisms. 

With Fiat, you can&hellip;

* Restrict access to specific [_accounts_](#accounts).
* Restrict access to specific [_applications_](#applications).
* Run pipelines using [automated triggers](#automated-pipeline-triggers) against access-controlled applications.
* Use and periodically update user roles from a backing [role provider](#role-providers).

Permissions can be attached to applications and (provider) accounts. A permission associates a role with one of these
 options: `READ`, `WRITE`, or `EXECUTE` (for apps only).
 

### Important notes

Keep these in mind as you consider your authorization strategy:

1) Fiat's authorization model open by default. In other words, when a resource does _not_
define who is allowed to access it, it is considered unrestricted.  This means:
   * If an account is unrestricted, any user with access to Spinnaker can deploy a new application
   to that account.
   * If an application is unrestricted, any user with access to Spinnaker can deploy that
   application into a different account. They may also be able to see basic information like
   instance names and counts within server groups.

1)  Every permission in Spinnaker is granted to a role. Individual users cannot be granted permissions. You also grant
 [Super admin](/setup/security/admin/) access to a role. You may see discussions of users in Fiat’s implementation but
  it’s just an optimization in the storage to not recompute user → roles → permissions.

1)  Account and application access control can be confusing unless you understand the core
relationship: accounts can contain multiple applications, and applications can span multiple
accounts.  Giving access to an account does not grant access to the application and vice versa.  Sometimes you need 
both permissions to perform certain actions.
![relationship between accounts and applications](application-account-relationship.png)


### Requirements

* [Authentication](../authentication) successfully setup in Gate.

* Configured Front50 to use S3 or Google Cloud Storage (GCS) as the backing storage mechanism for
 persistent application configurations.

* An external role provider from one of the following:
    * Google Groups via a G Suite Account
        * With access to the G Suite Admin console
    * GitHub Team
    * LDAP server
    * SAML Identity Provider (IdP) that includes groups in the assertion
        > SAML roles are fixed at login time, and cannot be changed until the user needs to
        reauthenticate.

* Enable the [authorization](/reference/halyard/commands/#hal-config-security-authz-enable) feature.

* Patience&mdash;there are a lot of small details that must be _just_ right with anything related to
 authentication and authorization.

* (Highly Suggested) All Spinnaker component microservices are either:
    * Firewalled off as a collective group, or:

        ![all service firewalled off](fiat-firewall.png)

    * Use mutual TLS authentication:

        ![all services use mutual TLS authentication](fiat-mTLS.png)



## Implementation

### Accounts
 Because Clouddriver is the source of truth for accounts, Fiat reaches out to Clouddriver
to gather the list of available accounts. There are two types of access restrictions to an account: `READ` and 
`WRITE`. Users must have at least one `READ` permission of an account to view the account's cloud resources, and at 
least one `WRITE` permission to make changes to the resources.

These halyard commands manage the `READ` and `WRITE` permissions.

```bash
PROVIDER= # Your cloud provider

hal config provider $PROVIDER account edit $ACCOUNT \
  --add-read-permission role1 \ # Adds a READ permission
  --add-write-permission role2 \ # Adds a WRITE permission
  --remove-read-permission role3 \ # Removes a READ permission
  --remove-write-permission role4 # Removes a WRITE permission

# Alternatively, you can overwrite the whole read or write list, comma delimited.
hal config provider $PROVIDER account edit $ACCOUNT \
  --read-permissions role1,role2,role3 \
  --write-permissions role1,role2,role3
```

### Applications
Before Spinnaker 1.14, there were two types of restrictions to an application `READ` and `WRITE`.
In the 1.14 release, a new permission type called `EXECUTE` was added. For any new applications,
the permission required to trigger pipelines changes from groups with `READ` access to those with
`EXECUTE` access.

To maintain backward compatibility for existing applications, groups with `READ` access will implicitly
get `EXECUTE` access. There are two ways to change this behavior:

* Modify the application config in the UI to explicitly add `EXECUTE` permissions to a group for an application:

{% include figure
   image_path="./applications_permissions.png"
%}

* Flip the default behavior across all applications to only grant `WRITE` users implicit `EXECUTE` access by
setting the following property in `fiat-local.yml`:

```yml
  fiat.executeFallback: 'WRITE'
```

### Examples of required permissions

- To delete a load balancer in account Z, you need to have `WRITE` permission on the account.
- To update a pipeline in an app, you need `WRITE` permission on that app.
- Since version 1.14, you can run a pipeline with just the `EXECUTE` permission.
- To successfully run a pipeline in app X that deploys to account Y, you need (at least)  `EXECUTE` on the app X and
 `WRITE` on the account Y.

## Role Providers
In Spinnaker there are a few ways you can associate a role with a user:

- With a file that contains user ↔ role (YAML parseable map with [user]: list of roles)
- Via [GitHub teams](./github-teams/): roles are the teams a user belongs to in a configured Org
- Via [Google Groups](./google-groups/): roles are mapped (see settings) from the Google directory
- Via [LDAP](./ldap/): roles are searched in LDAP from the user
- Via [SAML Groups](./saml/) (also covers OAuth ONLY with OIDC): The authentication method can also bring its own roles. In this case, roles are referred
 in Fiat as `EXTERNAL`. They can be used in addition to authorization roles.
 
In all these methods, users are referenced by a userId which is determined by the authentication method of your choice.

## Effects of restrictions

Because of the new access restrictions, `https://localhost:9000/#/applications` should no longer
list applications that have been restricted. Even navigating to the previously accessible page
should be denied:

![chrome network traffic is returning 403 Forbidden errors](restricted-network-traffic.png)

## Automated pipeline triggers

A popular feature in Spinnaker is the ability to run pipelines automatically based on a
triggering event, such as a `git push` or a Jenkins build completing. When pipelines run against
accounts and applications that are protected, it is necessary to configure
them with enough permissions to access those protected resources. This can
be done in two ways:

* Using [Pipeline Permissions](./pipeline-permissions/)
* Using a Fiat [service account](./service-accounts/)

## Reference Documentation
[Deeper details on Authorization in Spinnaker](/reference/architecture/authz_authn/authorization/)
