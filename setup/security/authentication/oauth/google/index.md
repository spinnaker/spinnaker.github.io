---
title:  "G Suite"
sidebar:
  nav: setup
---

This page instructs you on how to obtain an OAuth 2.0 client ID and client secret for use with your G Suite organization
(previously known as Google Apps for Work).

## Get client id and secret
1. Navigate to [https://console.developers.google.com/apis/credentials](https://console.developers.google.com/apis/credentials).
2. Click "Create credentials" --> OAuth client ID.
3. Select "Web Application", and enter a name.
4. Under "Authorized redirect URIs", add `https://localhost:8084/login`, replacing domain with your Gate address,
 if known, and `https` with `http` if appropriate. Click Create.
5. Note the generated client ID and client secret. Copy these to a safe place.

![GCP console to create OAuth 2.0 client screenshot](gcp-oauth-client.png)



## Setup Halyard
```bash
hal config security authn oauth2 edit --provider google \
  --client-id (client id from above) \
  --client-secret (client secret from above)

hal config security authn oauth2 enable

```


