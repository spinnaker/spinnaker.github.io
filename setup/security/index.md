---
layout: single
title:  "Security"
sidebar:
  nav: setup
---

Spinnaker has multiple options for both authentication and authorization. Instead of reinventing 
yet-another-login system, Spinnaker hooks into a login system your organization probably already 
has, such as OAuth 2.0, SAML, or LDAP.

For authorization, Spinnaker similarly leverages a role-provider that your organization may already
have set up, including Google Groups, GitHub Teams, or LDAP groups.
 
## Table of Contents

* Overview (this page)
* [Authentication](./authentication/)
  * [SSL](./authentication/ssl/)
  * [Network Architecture](./authentication/network-arch/)
  * [Methods](./authentication/methods/)
    * [OAuth 2.0](/setup/security/authentication/oauth)
    * [SAML](/setup/security/authentication/saml)
    * LDAP
    * X.509
* [Authorization](./authorization/)
  * Google Groups
  * GitHub Teams
  * SAML
  * LDAP
