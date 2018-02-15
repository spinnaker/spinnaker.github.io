---
title:  "Microsoft Azure"
sidebar:
  nav: setup
---

This page instructs you on how to obtain an OAuth 2.0 client ID and client secret for use with your Microsoft Azure tenant.

## Setting up an Azure Application Registration

1. Navigate to [https://portal.azure.com](https://portal.azure.com) and log in with your Azure credentials.
2. On the left hand navigation pane, click "Azure Active Directory" --> "App registrations".
3. Click "New application registration", and fill in the details:
   - Name of the application: (eg Spinnaker),
   - Application type: Web app / API
   - Sign-on URL: https://localhost:8084/login (replace localhost with your Gate address if known, and `https` with `http` if appropriate)
   - Click "Create"
4. Note the "Application ID", this is the client-id to pass to hal. Copy it to a safe place.
5. Click "Settings" -> "Keys". Under "Passwords", add a Key Description (eg Spinnaker), set the expiry and then click "Save".
   "Value" will now be populated. This is your client-secret, copy it to a safe place.

## Applying the settings in hal

Set up oauth2 with azure:

`hal config security authn oauth2 edit --provider azure --client-id (client id from above)  --client-secret (client secret from above)`

The Tenant ID of your organization is required for Azure OAuth2.0 login. To obtain it:
1. Navigate to [https://portal.azure.com](https://portal.azure.com) and log in with your Azure credentials.
2. On the left hand navigation pane, click "Azure Active Directory" --> "Properties".
3. "Directory ID" is your Tenant ID.

In order to pass the Tenant ID to gate, we need to insert is as an environment variable. Add the following to ~/.hal/default/service-settings/gate.yaml:
```
env:
  azureTenantId: (your tenant id)
```

Now enable OAuth2 using hal:

`hal config security authn oauth2 enable`
