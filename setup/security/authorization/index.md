---
layout: single
title:  "Authorization"
sidebar:
  nav: setup
---

{% include toc %}

Much like authentication, Spinnaker allows for a variety of pluggable 
authorization mechanisms. This page will illustrate how to setup and configure **Fiat**, 
Spinnaker's authorization microservice.

## Model and Features

Fiat's authorization model is a _whitelist that is open by default_. In other words, when a 
resource does _not_ define who is allowed to access it, it is considered unrestricted. 

Fiat enables the ability to:

* Restrict access to specific _accounts_.
* Restrict access to specific _applications_.
* Run externally-triggered pipelines against access-controlled applications using _Fiat service accounts_.
* Use and periodically update user roles from a backing provider

## Requirements

1. [Authentication](../authentication) successfully setup in Gate.

1. Configured Front50 to use S3 or Google Cloud Storage (GCS) as the backing storage mechanism for
 persistent application configurations.

1. An external role provider from one of the following:
    * Google Groups via a G Suite Account
        * With access to the G Suite Admin console
    * GitHub Team
    * LDAP server
    * SAML Identity Provider (IdP) that includes groups in the assertion 
        > SAML roles are fixed at login time, and cannot be changed until the user needs to 
        reauthenticate.

1. Patience - there are a lot of small details that must be _just_ right with anything related to
 authentication and authorization.

1. (Highly Suggested) All Spinnaker component microservices are either:
    1. Firewalled off as a collective group, or:
    
    ![all service firewalled off](fiat-firewall.png)
    
    1. Use mutual TLS authentication:
    
    ![all services use mutual TLS authentication](fiat-mTLS.png)

## Role Providers

To configure an external role provider, follow one of the instructions below:

* [Google Groups with a G Suite account](./google-groups/)
* [GitHub Teams](./github-teams/)
* [LDAP Groups](./ldap/)
* [SAML Groups](./saml/)
