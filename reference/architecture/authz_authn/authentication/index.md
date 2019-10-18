---
layout: single
title:  "Authentication Architecture"
sidebar:
  nav: reference
---

{% include toc %}

## Authentication

There are three basic players in Spinnaker's authentication workflow:

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

1. **Deck**: Spinnaker's UI. Consists of a set of static HTML, JavaScript, and CSS files. Generally
 served from an Apache server, but there is nothing special about Apache that makes Deck work.
 Replace with your favorite HTTP(S) server if you'd like.

1. **Gate**: Spinnaker's API Gateway. All traffic (including traffic generated from Deck) flows
through Gate. It is the point at which _authentication_ is confirmed and one point (of several)
where _authorization_ is enforced.

1. **Identity Provider**: This is your organization's OAuth 2.0, SAML 2.0, or LDAP service. X.509
client certificates can be used in addition to any of these services or as a standalone identity provider.

### Workflow

Deck is a Javascript Single Page Application (SPA). This means that when a user leaves the page to enter their credentials, the entire application gets loaded again when they return. As a result, the
process below involves numerous redirects between the three parties (Deck, Gate, and the
Identity Provider).

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
an _unprotected_ URL but will only return the currently logged in user.

    If a user is found - all done!
    
1. Without a user logged in, Deck requests a _protected_ URL: `https://gate.url:8084/auth/redirect?to=https://deck.url:9000`.

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
	
1. Given that the URL is protected, Gate sees that there is no logged-in user, so it issues an HTTP 302
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
1. In the case of LDAP, the `/login` page is hosted in Gate and is a basic form asking for credentials. Gate attempts to
 establish a session (preferably over SSL) with the LDAP server, sending the username and password.   If successful,
 the session is established. Otherwise, a “Bad Credentials” exception is thrown.  For SAML/OAauth methods, these 
 will redirect to the appropriate login page for the IDP.

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

1. Repeat this process from step 1. Now, the response from `https://gate.url:8084/auth/user` will contain a proper JSON object and the rest of the application will proceed to load.


## OAuth Workflow

The OAuth specification defines numerous flows for various scenarios. Spinnaker utilizes the
**_authorization code flow_**, more commonly known as the three-legged OAuth.  The three-legged
OAuth
flow looks like:

<div class="mermaid">
    sequenceDiagram

    participant Deck
    participant Gate
    participant IdentityProvider
    participant ResourceServer

    Deck->>+Gate: GET /something/protected
    Gate->>-Deck: HTTP 302 to /login
    Deck->>+Gate: GET /login
    Gate->>-Deck: HTTP 302 to https://idp.url/userLogin?client_id=foo...

    Deck->>+IdentityProvider: GET https://idp.url/userLogin?client_id=foo...
    IdentityProvider->>-Deck: Returns login page
</div>

1. User attempts to access a protected resource.

1. Gate redirects to OAuth provider, passing the following important bits:
    * `client_id`: A pre-established identifier for this Gate instance.
    * `redirect_uri`: Where to send the user after login. Must be accessible by the user's
    browser.

    > Gate attempts to intelligently guess the `redirect_uri` value, but outside components like
    SSL terminating load balancers can cause this guess to be wrong. See
    [SSL documentation](/setup/security/ssl/#network-configurations) for how to fix this.

    * `response_type=code`: Indicating that we are performing the three-legged OAuth flow.
    * `scope`: What data or resources Gate would like access to. This is generally something like
    `email profile` to access the user's email address.

1. OAuth provider prompts user for username & password.
    <div class="mermaid">
        sequenceDiagram

        participant Deck
        participant Gate
        participant IdentityProvider
        participant ResourceServer

        Deck->>+IdentityProvider: User sends credentials
        IdentityProvider->>-Deck: Confirms client_id 'foo' can access user's information
        Deck->>+IdentityProvider: User confirms
        IdentityProvider->>-Deck: HTTP 302 to https://gate.url/login?code=abcdef
    </div>

1. OAuth provider confirms that the user is granting Gate access to his profile.

1. Using the `redirect_uri`, the OAuth provider redirects the user to this address, providing an
additional `code` parameter.

    <div class="mermaid">
        sequenceDiagram

        participant Deck
        participant Gate
        participant IdentityProvider
        participant ResourceServer

        Deck->>+Gate: GET /login?code=abcdef
        Gate->>+IdentityProvider: POST /token "{code:abcdef, client_id:..., client_secret:...}"
        IdentityProvider->>-Gate: Responds with access token `12345`
        Gate->>+ResourceServer: GET /userInfo with "Authorization: Bearer 12345" header
        ResourceServer->>-Gate: Respondes with JSON of user profile information
        Note left of Gate: Gate extracts data based on userInfoMapping
        Gate->>-Deck: HTTP 302 to originally requested URL
    </div>

1. Gate uses this `code` parameter to request an _access token_ from the OAuth provider's token
server.

1. Gate uses the _access token_ to request user profile data from the resource server
(`security.oauth2.resource.userInfoUri`).

1. Gate uses the `userInfoMapping` to extract specific fields from the response, such as the
username and email address, and associates it with the established session cookie with the user.
See UserInfoMapping below.


The authorization code flow is the most secure way to get this data, because the _access token_
is never revealed outside of the server using it.

{% include mermaid %}

{% include mermaid %}
