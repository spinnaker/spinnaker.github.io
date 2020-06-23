---
title:  "Microsoft Azure"
sidebar:
  nav: setup
---

This page instructs you on how to obtain an OAuth 2.0 client ID and client secret for
use with your Microsoft Azure tenant. More extensive documentation is available on
[Microsoft's site](https://docs.microsoft.com/en-us/azure/active-directory/azuread-dev/v1-protocols-oauth-code).

## Setting up an Azure Application Registration

1. Navigate to [https://portal.azure.com](https://portal.azure.com) and log in with your Azure credentials.
2. On the left hand navigation pane, click "Azure Active Directory" --> "App registrations".
3. Click "New application registration", and fill in the details:
   - Name of the application: (eg Spinnaker),
   - Application type: Web app / API
   - Sign-on URL: https://localhost:8084/login (replace localhost with your Gate address if known, and `https` with `http` if appropriate)
   - Click "Create"
4. Note the "Application ID", this is the client ID to pass to hal. Copy it to a safe place.
5. Click "Settings" -> "Keys". Under "Passwords", add a Key Description (eg Spinnaker), set the expiry and then click "Save".
   "Value" will now be populated. This is your client secret; copy it to a safe place.

## Configure Halyard

You may configure Halyard either with the CLI or by manually editing the hal config.

### Hal config

```yaml
security:
  authn:
    oauth2:
      enabled: true
      client:
        clientId: # client ID from above
        clientSecret: # client secret from above
        accessTokenUri: https://login.microsoftonline.com/${azureTenantId}/oauth2/token
        userAuthorizationUri: https://login.microsoftonline.com/${azureTenantId}/oauth2/authorize?resource=https://graph.windows.net
        clientAuthenticationScheme: query
        scope: profile
      # You may want to restrict access to your Spinnaker by adding
      # userInfoRequirements to further restrict access beyond beyond simply
      # requiring that users have a valid account in your Azure AD Tenant.
      userInfoRequirements: {}
      resource:
        userInfoUri: https://graph.windows.net/me?api-version=1.6
      userInfoMapping:
        email: userPrincipalName
        firstName: givenName
        lastName: surname
      provider: AZURE
```

### CLI

Set up OAuth 2.0 with azure:

`hal config security authn oauth2 edit --provider azure --client-id (client ID from above)  --client-secret (client secret from above)`

Now enable OAuth 2.0 using hal:

`hal config security authn oauth2 enable`


## Set environment variable
The Tenant ID of your organization is required for Azure OAuth 2.0 login. To obtain it:
1. Navigate to [https://portal.azure.com](https://portal.azure.com) and log in with your Azure credentials.
2. On the left hand navigation pane, click "Azure Active Directory" --> "Properties".
3. "Directory ID" is your Tenant ID.

In order to pass the Tenant ID to gate, we need to insert is as an environment variable. Add the following to ~/.hal/default/service-settings/gate.yml:
```
env:
  azureTenantId: (your tenant id)
```
