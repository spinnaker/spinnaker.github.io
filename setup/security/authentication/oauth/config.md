---
title:  "OAuth 2.0 Configuration"
sidebar:
  nav: setup
---

## Halyard config

The full schema for configuring OAuth 2.0 via Halyard is:
```yaml
security:
  authn:
    oauth2:
      # Whether OAuth 2.0 is enabled.
      enabled: boolean
      client:
        # The OAuth client ID you have configured with your OAuth 2.0 provider.
        clientId: string
        
        # The OAuth client secret you have configured with your OAuth provider.
        clientSecret: string 
          
        # The access token URI for your OAuth provider.
        accessTokenUri: string
          
        # The user authorization URI for your OAuth 2.0 provider.
        userAuthorizationUri: string
          
        # The scope to request when obtaining an access token from your
        # OAuth 2.0 provider.
        scope: string

        # The externally accessible URL for Gate. For use with load balancers
        # that do any kind of address manipulation for Gate traffic, such as an
        # SSL terminating load balancer.
        preEstablishedRedirectUri: string
          
        # The method used to transmit authentication credentials to your
        # OAuth 2.0 provider; defaults to header.
        clientAuthenticationScheme: [header|query|form|none]
          
        # Whether the current URI in the request should be preferred over the
        # pre-established redirect URI.
        useCurrentUri: boolean
        
      resource:
        # The user info URI for your OAuth 2.0 provider.
        userInfoUri: string
        
      # Mapping of user attributes to fields returned by your OAuth 2.0 provider.
      # This field controls how the fields returned from the OAuth 2.0 provider's
      # user info endpoint are translated into a Spinnaker user.
      userInfoMapping:
        email: string
        firstName: string
        lastName: string
        username: string
        
      # The map of requirements the userInfo request must have. This is used to
      # restrict user login to specific domains or to users having a specific attribute.
      userInfoRequirements: map<string, string>
```

## Halyard CLI commands

There are Halyard CLI commands to edit each field above; these are documented
[here](https://www.spinnaker.io/reference/halyard/commands/#hal-config-security-authn-oauth2).
