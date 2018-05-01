---
layout: single
title:  "Authentication"
sidebar:
  nav: setup
redirect_from: /setup/security/authentication/network-arch/

---

{% include toc %}

Spinnaker's authentication mechanism is pluggable for a variety of different login sources. This
page will guide you through the _overall_ request/response flow that happens when your users login.

## Introduction

There are 3 basic players in Spinnaker's authentication workflow:

<div class="mermaid">
graph LR
classDef default fill:#d8e8ec,stroke:#7a8288;
linkStyle default stroke:#7a8288, stroke-width:2px, fill:none;

gate(Gate)
idp(IdentityProvider)
deck(Deck/Browser)

deck-->gate
gate-->deck
deck-->idp
idp-->deck
</div>

1. **Gate**: Spinnaker's API Gateway. All traffic (including traffic generated from Deck) flows
through Gate. It is the point at which _authentication_ is confirmed and one point (of several)
where _authorization_ is enforced.

1. **Deck**: Spinnaker's UI. Consists of a set of static HTML, JavaScript, and CSS files. Generally
 served from an Apache server, but there is nothing special about Apache that makes Deck work.
 Replace with your favorite HTTP(S) server if you'd like.

1. **Identity Provider**: This is your organization's OAuth 2.0, SAML 2.0, or LDAP service. X.509
client certificates can be used in addition to any of these services, or used standalone.

## Incognito mode

![Incognito logo](./incognito.png){:width="50px"}

Getting the authentication workflow _just_ right rarely happens on the first try. Each login attempt
 during configuration (or development) causes a new session to be established in Gate's session
 repository. Re-using these sessions is undesirable when testing configuration changes.

We highly recommend using Google Chrome's
[Incognito mode](https://support.google.com/chrome/answer/95464?source=gsearch&hl=en) when working
with configuration changes.

1. Open a new Incognito window
1. Navigate to your Spinnaker's Deck endpoint
1. Observe behavior and make configuration change. Restart affected Spinnaker service.
1. Close Incognito window
1. Repeat from step 1.

A common gotcha with incognito windows is that they _all share the same cookie jar_. This means that
 when you want to test a new configuration change, you need to close **_all_** incognito windows.
 Otherwise, the session cookie will not be deleted.

## Workflow

Deck is a Javascript Single Page Application (SPA), which means that when we leave the page to let
the user enter their credentials, we must reload the entire thing when we return. As a result, the
process below involves numerous redirects between the three parties (Deck, Gate, and the
Authentication provider).

<div class="mermaid">
    sequenceDiagram

    participant Apache
    participant Deck
    participant Gate
    participant IdentityProvider

    Deck->>+Apache: GET deck.url
    Apache->>-Deck: Returns Deck's landing page

    Deck->>+Gate: GET /auth/user for user's identity
    Note right of Gate: No or expired session cookie.
    Gate->>-Deck: Returns empty response
</div>

1. Browser requests Deck's landing page: `https://deck.url:9000/`

1. Deck checks for the user's identity: `https://gate.url:8084/auth/user`. Specifically, a user is
logged in if the response contains a JSON object with a non-null "username" field. `/auth/user` is
an _unprotected_ URL, but will only return the currently logged in user.

    a. If a user is found - all done!

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
	</div>

1. Without a user logged in, Deck requests a _protected_ URL: `https://gate.url:8084/auth/redirect?to=https://deck.url:9000`.

1. Given that the URL is protected, Gate sees that there is no logged in user, so it issues a HTTP 302
redirect to an authentication-method-specific page. It saves the requested URL
(`https://gate.url:8084/auth/redirect?to=https://deck.url:9000`) in the session state.

    <div class="mermaid">
		sequenceDiagram
		participant Deck
		participant Gate
		participant IdentityProvider

		Deck->>+IdentityProvider: Login credentials
		Note right of IdentityProvider: Success!
		IdentityProvider->>-Deck: HTTP 302 to https://gate.url/login?success

        activate Gate
		Deck->>+Gate: GET /login?success
		Gate->>+IdentityProvider: Optionally retrieve validation info
		IdentityProvider->>-Gate: .
		deactivate Gate
	</div>

1. The user logs into the authentication provider.

1. The authentication provider sends a request back to Gate, usually through redirects of the user's
 browser.

1. Gate processes the received data. This can include making additional requests to confirm the
user's identity.

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


{% include mermaid %}

## Next steps

Learn how to configure Spinnaker to communicate over [SSL](./ssl).
