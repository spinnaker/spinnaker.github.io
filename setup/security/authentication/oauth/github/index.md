---
title:  "GitHub Teams"
sidebar:
  nav: setup
---


Go to https://github.com/settings/applications/new

```bash
hal config security authn oauth2 edit --provider github \
  --client-id (client id from above) \
  --client-secret (client secret from above)

hal config security authn oauth2 enable

```

