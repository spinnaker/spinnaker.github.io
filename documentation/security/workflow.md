---
title:  "Authentication Workflow"
sidebar:
  nav: security
---
{% include toc %}

<script src="https://cdn.rawgit.com/knsv/mermaid/6.0.0/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({
    startOnLoad:true,
    sequenceDiagram: {
      mirrorActors: true,
      messageMargin: 75,
      useMaxWidth: true,
      width: 200
    }
  });
</script>

## The Dance
Deck is a Javascript Single Page Application (SPA), which means that when we leave the page to let the user enter their credentials, we must reload the entire thing when we return. As a result, the process below involves numerous redirects between the three parties (Deck, Gate, and the Authentication provider).

<!-- ![](dance-10.png) -->

<div class="mermaid">
sequenceDiagram

participant Apache
participant Deck
participant Gate
participant IdentityProvider

Deck->>Apache: GET deck.url
Apache->>Deck: Returns Deck's landing page

Deck->>+Gate: GET /auth/user for user's identity
Note right of Gate: No or expired session cookie.
Gate->>-Deck: Returns empty response

</div>

1. Browser requests Deck's landing page: `https://deck.url:9000/`

1. Deck checks for the user's identity: `https://gate.url:8084/auth/user`. Specifically, a user is logged in if the response contains a JSON object with a non-null "username" field. `/auth/user` is an _unprotected_ URL, but will only return the currently logged in user.

    a. If a user is found - all done!

    <!-- ![](dance-20.png) -->

	<div class="mermaid">
		sequenceDiagram
		participant Deck
		participant Gate
		participant IdentityProvider

		Deck->>+Gate: GET /auth/redirect?to=deck.url
		Note right of Gate: URL is protected. Save URL in session, start login process.
		Note right of Gate: Redirect URL is auth-mechanism dependent)
		Gate->>-Deck: HTTP 302 to /login

		Deck->>+Gate: GET /login
		Gate->>-Deck: HTTP 302 to Identity Provider

		Deck->>+IdentityProvider: GET https://idp.url/?redirect_uri=gate.url/login
		IdentityProvider->>-Deck: Login Page

		Deck->>IdentityProvider: Login credentials
		Note right of IdentityProvider: Success!
	</div>

1. Without a user logged in, Deck requests a _protected_ URL: `https://gate.url:8084/auth/redirect?to=https://deck.url:9000`.

1. Given that the URL is protected, Gate sees that there is no logged in, and issues an HTTP 302 redirect to an authentication-method-specific page. It saves the requested URL (`https://gate.url:8084/auth/redirect?to=https://deck.url:9000`) in the session state.

1. The user logs into the authentication provider.

    <!-- ![](dance-30.png) -->

	<div class="mermaid">
		sequenceDiagram
		participant Deck
		participant Gate
		participant IdentityProvider

		IdentityProvider->>Deck: HTTP 302 to https://gate.url/login?success

		Deck->>+Gate: GET /login?success
		Gate-->>IdentityProvider: Optionally retrieve validation info
		activate IdentityProvider
		IdentityProvider-->>Gate: .
		deactivate IdentityProvider
	</div>

1. The authentication provider sends a request back to Gate, usually through redirects of the user's browser.

1. Gate processes the received data. This can include making additional requests to confirm the user's identity.

    <!-- ![](dance-40.png) -->

	<div class="mermaid">
		sequenceDiagram
		participant Deck
		participant Gate
		participant IdentityProvider

		activate Gate
		Note right of Gate: Retrieved saved URL from session.
		Gate->>-Deck: HTTP 302 /auth/redirect?to=deck.url

		Deck->>+Gate: GET /auth/redirect?to=deck.url
		Note right of Gate: URL is protected, but user is authenticated. Proceed!
		Gate->>-Deck: HTTP 302 to deck.url
	</div>



1. Upon successful processing, the user is now considered logged in. Gate retrieves the originally requested URL from the session state. It issues an HTTP 302 to that URL (`https://gate.url:8084/auth/redirect?to=https://deck.url:9000`).

1. The request from the browser hits the API gateway, along with the session cookie from the newly logged in user. The `to` query parameter is validated to be the associated Deck instance, and a final HTTP 302 is sent, directing the user to the `https://deck.url:9000`.

    <!-- ![](dance-50.png) -->

	<div class="mermaid">
		sequenceDiagram
		participant Apache
		participant Deck
		participant Gate

		Deck->>+Apache: GET deck.url
		Apache->>-Deck: .

		Deck->>+Gate: GET /auth/user
		Note right of Gate: Valid session cookie, user is authenticated!
		Gate->>-Deck: {'username': 'foo'}
		activate Deck
		Note right of Deck: User logged in! Huzzah!
		deactivate Deck
	</div>

1. Repeat this process from step 1. Now, the response from `https://gate.url:8084/auth/user` will contain a proper JSON object and the rest of application will proceed to load.
