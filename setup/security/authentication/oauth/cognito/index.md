---
title:  "AWS Cognito"
sidebar:
  nav: setup
---

This page instructs you on how to obtain an OAuth 2.0 client ID and client secret for
use with your AWS Cognito User Pools.

## Setting up an AWS Cognito App Client

1. Navigate to [https://aws.amazon.com/cognito/](https://aws.amazon.com/cognito/) and log in with your AWS credentials.
2. Search for Cognito in the search bar.
3. Select the user pools you want Spinnaker to use.
4. At the side bar under "General settings", select "App clients", add a client.
  - Make sure you select "Generate client secret."
5. After that go to "App integration", then to "App client settings."
  a) Select "Cognito User Pool" as one of the "Enabled Identity Providers."
  b) Input your callback URL.
  c) Check the following
    - Authorization code grant, Implicit grant
    - email, openid
  d) Also make sure you already have a domain name for your hosted UI
  
Have these credentials ready before moving on to the next step
- App client id
- App client secret
- Hosted UI domain name

## Configure Halyard

You can configure Halyard either with the [CLI](/reference/halyard/commands/) or by manually editing the hal config.

### Hal config

```yaml
security:
  authn:
      oauth2:
        enabled: true
        client:
          clientId: {CLIENT_ID}
          clientSecret: {CLIENT_SECRET}
          accessTokenUri: {YOUR_DOMAIN_NAME}/oauth2/token
          userAuthorizationUri: {YOUR_DOMAIN_NAME}/oauth2/authorize
          preEstablishedRedirectUri: {GATE_URL}/login
          useCurrentUri: false
        resource:
          userInfoUri: {YOUR_DOMAIN_NAME}/oauth2/userInfo
        userInfoMapping: {}
        provider: OTHER
```

### CLI

1. Set up OAuth 2.0 with AWS Cognito:

`hal config security authn oauth2 edit --provider OTHER --client-id (client ID from above)  --client-secret (client secret from above) --access-token-uri (your domain name)/oauth2/token --user-authorization-uri (your domain name)/oauth2/authorize --user-info-uri (your domain name)/oauth2/userInfo`

2. Enable OAuth 2.0 using:

`hal config security authn oauth2 enable`
