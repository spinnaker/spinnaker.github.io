---
title:  "Authentication Workflow"
sidebar:
  nav: security
---
{% include toc %}

## The Dance
Deck is a Javascript Single Page Application (SPA), which means that when we leave the page to let the user enter their credentials, we must reload the entire thing when we return. As a result, the process below involves numerous redirects between the three parties (Deck, Gate, and the Authentication provider).

TODO: Image of steps 1-3

1. Browser requests Deck's landing page: `https://deck.url:9000/`

1. Deck checks for the user's identity: `https://gate.url:8084/auth/user`. Specifically, a user is logged in if the response contains a JSON object with a non-null "email" field. `/auth/user` is an _unprotected_ URL, but will only return the currently logged in user.

    a. If a user is found - all done!

1. Without a user logged in, Deck requests a _protected_ URL: `https://gate.url:8084/auth/redirect?to=https://deck.url:9000`.

1. Given that the URL is protected, Gate sees that there is no logged in, and issues an HTTP 302 redirect to an authentication-method-specific page. It saves the requested URL (`https://gate.url:8084/auth/redirect?to=https://deck.url:9000`) in the session state.

1. The user logs into the authentication provider.

1. The authentication provider sends a request back to Gate, usually through redirects of the user's browser.

1. Gate processes the received data. This can include making additional requests to confirm the user's identity.

1. Upon successful processing, the user is now considered logged in. Gate retrieves the originally requested URL from the session state. It issues an HTTP 302 to that URL (`https://gate.url:8084/auth/redirect?to=https://deck.url:9000`).

1. The request from the browser hits the API gateway, along with the session cookie from the newly logged in user. The `to` query parameter is validated to be the associated Deck instance, and a final HTTP 302 is sent, directing the user to the `https://deck.url:9000`.

1. Repeat this process from step 1. Now, the response from `https://gate.url:8084/auth/user` will contain a proper JSON object and the rest of application will proceed to load.

# Network Architecture Options with SSL/TLS
It is strongly encouraged that your entire communication with all three players is conducted over HTTPS. Most reasonable identity providers already run HTTPS-only, and you should look for a different solution provider if yours does not.

Each authentication mechnism is configured differently depending on where the SSL connection is terminated. Furthermore, the use of Spinnaker's all-in-one pre-built image adds a different configuration wrinkle when trying to add authentication.

Many users like to get authentication working before adding HTTPS, but experience bears out that the transition is not smooth. It is recommended to put at least a temporary SSL solution in place **first**.
