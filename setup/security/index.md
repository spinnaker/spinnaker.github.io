---
layout: single
title:  "Overview"
sidebar:
  nav: setup
redirect_from: /docs/securing-spinnaker
---

{% include toc %}


Spinnaker has multiple options for both authentication and authorization. Instead of reinventing
yet-another-login system, Spinnaker hooks into a login system your organization probably already
has, such as OAuth 2.0, SAML, or LDAP.

For authorization, Spinnaker similarly leverages a role-provider that your organization may already
have set up, including Google Groups, GitHub Teams, SAML Roles or LDAP groups.  

See also [`hal config security`](/reference/halyard/commands/#hal-config-security).

## Contents

* Overview (this page)
* [SSL](./ssl)
* Authentication
  * [Overview](./authentication/)
  * Methods
    * [OAuth 2.0](./authentication/oauth/)
    * [SAML](./authentication/saml/)
    * [LDAP](./authentication/ldap/)
    * [X.509](./authentication/x509/)
* Authorization 
  * [Overview](./authorization/)
  * Role Providers
      * [Google Groups](./authorization/google-groups/)
      * [GitHub Teams](./authorization/github-teams/)
      * [LDAP](./authorization/ldap/)
      * [SAML](./authorization/saml/)
  * [Service Accounts](./authorization/service-accounts/)
  * [Pipeline Permissions](./authorization/pipeline-permissions/)
* [Administrator functionality](./admin/)


## For reference...
[Authorization & Authentication Architecture and workflow](/reference/architecture/authz_authn/)

## Next steps

Setup [authentication](./authentication/) for your Spinnaker deployment.
