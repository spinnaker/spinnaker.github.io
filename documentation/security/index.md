---
title:  "Authentication and Authorization"
sidebar:
  nav: security
---

{% include toc %}

Spinnaker has multiple options for both authentication and authorization. First, it is vitally important to understand the distinction between these two terms:

* **authentication**: validating that you are who you say you are.
* **authorization**: the granting of privledges to perform an action (e.g. see that a resource exists [READ access] or change its settings [WRITE access]).

Authorization is fundamentally flawed without first confirming the user is who they say they are.  You should get authentication working first before working on authorization.

There are 3 basic players in Spinnaker's authentication workflow:

<div class="mermaid">
graph LR
classDef default fill:#52adc8,stroke:#333;
linkStyle default stroke:#000, stroke-width:2px, fill:none;


gate(Gate)
idp(IdentityProvider)
deck(Deck/Browser)

deck-->gate
gate-->deck
deck-->idp
idp-->deck
</div>

1. **Gate**: Spinnaker's API Gateway. All traffic (including traffic generated from Deck) flows through Gate. It is the point at which _authentication_ is confirmed and one point (of several) where _authorization_ is enforced.

1. **Deck**: Spinnaker's UI. Consists of a set of static HTML, JavaScript, and CSS files. Generally served from an Apache server, but there is nothing special about Apache that makes Deck work. Replace with your favorite HTTP(S) server if you'd like.

1. **Identity Provider**: This is your organization's OAuth 2.0, SAML 2.0, or LDAP service. X.509 client certificates can be used in addition to any of these services, or used standalone.

## Incognito Mode

![Incognito logo](incognito.png){:width="50px"}

Getting the authentication workflow _just_ right rarely happens on the first try. Each login attempt during configuration (or development) causes a new session to be established in Gate's session repository. Re-using these sessions is undesirable when testing configuration changes.

We highly recommend using Google Chrome's [Incognito mode](https://support.google.com/chrome/answer/95464?source=gsearch&hl=en) when working with configuration changes.

1. Open a new Incognito window
1. Navigate to your Spinnaker's Deck endpoint
1. Observe behavior and make configuration change. Restart affected Spinnaker service.
1. Close Incognito window
1. Repeat from step 1.

A common gotcha with incognito windows is that they _all share the same cookie jar_. This means that when you want to test a new configuration change, you need to close **_all_** incognito windows. Otherwise, the session cookie will not be deleted.

<script src="https://cdn.rawgit.com/knsv/mermaid/6.0.0/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({
    startOnLoad:true
  });
</script>
