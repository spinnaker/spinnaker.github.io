---
title:  "OAuth 2.0 - SSL Load Balancer Termination"
sidebar:
  nav: authentication
---


Just like the pre-built VM image, we will override Gate's `redirect_uri` to point to the load balancer's endpoint.

1. Follow your cloud providers instructions for setting up an SSL-terminating load balancer.

1. Tell Gate to use the specified `redirect_uri` during the OAuth workflow.
    ```yaml
    spring:
      oauth2:
        client:
          useCurrentUri: false
          preEstablishedRedirectUri: https://load-balanced.gate.url:8084/login
    ```

1. Enable authentication and tell Deck to use the new Gate URL.

    1. **VMs**: Ensure the `/opt/deck/html/settings.js` resolves to:

      ```yaml
      window.spinnakerSettings = {
        authEnabled: true,
        gateUrl: https://load-balanced.gate.url:8084,
        ...
      }
      ```

    1. **Containers**: Add the following environmental variables:

        1. `AUTH_ENABLED=true`
        1. `API_HOST=https://load-balanced.gate.url:8084`

1. Restart Deck and Gate.
