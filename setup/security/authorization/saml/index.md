---
layout: single
title:  "SAML"
sidebar:
  nav: setup
---

{% include toc %}

The SAML use case is a special one - it's the only one where a user's roles cannot be dynamically 
updated. This is because the user's roles are sent in the initial authentication handshake between
Gate and the SAML Identity Provider (IdP).


## IdP Setup

To enable SAML roles, configure your IdP to include group membership in the assertion
(not covered - some providers may not offer this option). By default, Gate looks for the 
`memberOf` attribute statement, but this can be reconfigured in Gate’s settings.

When Fiat is enabled, SAML groups are automatically pushed to Fiat upon user login and cannot be 
updated until the user needs to reauthenticate.



## Configure with Halyard

SAML roles are automatically pushed to Fiat, so no further configuration is needed.

## Troubleshooting
