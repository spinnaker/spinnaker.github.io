---
title:  "SAML 2.0 - SSL Server Termination"
sidebar:
  nav: authentication
---


Terminating SSL within the Gate server is the de factor way to enable SSL for Spinnaker. This will work with or without a load balancer proxying traffic to this instance.

1. Follow the [SSL Setup]() instructions to generate your server public/private key pair in the proper format. Save this file to `/opt/spinnaker/config/keystore.jks`

1. Edit `/opt/spinnaker/config/gate-local.yml`:
    ```
    server:
      ssl:
        enabled: true
        keyStore: /opt/spinnaker/config/keystore.jks
        keyStorePassword: $YOUR_KEY_PASSWORD
        keyAlias: server # or whatever alias you used in the keystore.
    ```

1. Enable authentication and tell Deck to use the new Gate URL.

    1. **VMs**: Ensure the `/opt/deck/html/settings.js` resolves to:
        ```
        window.spinnakerSettings = {
          authEnabled: true,
          gateUrl: https://gate.url:8084,
          ...
        }
        ```
    1. **Containers**: Add the following environmental variables:

        1. `AUTH_ENABLED=true`
        1. `API_HOST=https://gate.url:8084`

1. Restart Deck and Gate.
