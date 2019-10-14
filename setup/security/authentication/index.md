---
layout: single
title:  "Authentication"
sidebar:
  nav: setup
---

{% include toc %}

 Spinnaker's authentication mechanism supports a variety of different login sources.  There are a lot of moving parts
getting this to work just right.  Here's some of the basics and tools that have made setup easier to configure and test.  

## Introduction

There are 3 basic systems involved with Spinnaker's authentication workflow.  The changes made will primarily be made
 to either your identity provider or gate.  Deck itself will not require changes or updates, but it's useful to
  understand how they interact.

<div class="mermaid">
graph LR
classDef default fill:#d8e8ec,stroke:#7a8288;
linkStyle default stroke:#7a8288, stroke-width:2px, fill:none;

gate(Gate)
idp(IdentityProvider)
deck(Deck/Browser)

deck-->gate
gate-->deck
deck-->idp
idp-->deck
</div>

1. **Deck**: Spinnaker's UI. Consists of a set of static HTML, JavaScript, and CSS files. Generally
 served from an Apache server, but there is nothing special about Apache that makes Deck work.
 Replace with your favorite HTTP(S) server if you'd like.  The javascript being an SPA is going to do 
 the communication with your identity provider.  Which IDP is determined by Gate.

1. **Gate**: Spinnaker's API Gateway. All traffic (including traffic generated from Deck) flows
through Gate. It is the point at which _authentication_ is confirmed and one point (of several)
where _authorization_ is enforced.  

1. **Identity Provider**: This is your organization's OAuth 2.0, SAML 2.0, or LDAP service. X.509
client certificates can be used in addition to any of these services, or used standalone.

## Incognito mode

![Incognito logo](./incognito.png){:width="50px"}

Getting the authentication working rarely happens on the first try. Each login attempt
 during configuration (or development) causes a new session to be established in Gate's session
 repository. Re-using these sessions is undesirable when testing configuration changes.

We highly recommend using Google Chrome's [Incognito
mode](https://support.google.com/chrome/answer/95464?source=gsearch&hl=en){:target="\_blank"}
when working with configuration changes.

1. Open a new Incognito window
1. Navigate to your Spinnaker's Deck endpoint
1. Observe behavior and make configuration change. Restart affected Spinnaker service.
1. Close Incognito window
1. Repeat from step 1.

A common gotcha with incognito windows is that they _all share the same cookie jar_. This means that
 when you want to test a new configuration change, you need to close **_all_** incognito windows.
 Otherwise, the session cookie will not be deleted.


{% include mermaid %}


## Available options
* Methods
    * [OAuth 2.0/OIDC](./oauth/) The main examples are Google & Github end points.  
    * [SAML](./saml/) - Lots of examples on this with one of the most prevalent being Okta.  
    * [LDAP](./ldap/) - This covers Active Directory and other LDAP servers (aka OpenLdap).
    * [X.509](./x509/) - Often used for client or application communications.  Can operate in conjunction with other authentication methods.  

## Next steps

Setup [Authorization](/setup/security/authorization/).

Learn how to configure Spinnaker to communicate over [SSL](/setup/security/ssl).
