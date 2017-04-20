---
title:  "OAuth 2.0"
sidebar:
  nav: setup
---

{% include toc %}

OAuth 2.0 is the preferred way authenticate and authorize third parties access to your data guarded 
by the identity provider. To confirm your identity, Spinnaker requests access to your email address 
from your identity provider.


## OAuth Providers

### Pre-configured Providers

For convenience, several providers are already pre-configured. As an administrator, you merely have
 to activate one, and give the client ID and secret. Follow the Provider-Specific documentation to
 obtain your client ID and client secret.

Provider | Halyard value | Provider-Specific Docs
--- | --- | ---
Google Apps for Work / G Suite | `google` | [Google Apps for Work / G Suite](./providers/google/)
GitHub | `github` | [GitHub Teams](./providers/github/)
Azure | `azure` | [Azure](./providers/azure/)

Activate one by executing the following:

```
CLIENT_ID=myClientId
CLIENT_SECRET=myClientSecret
PROVIDER=google|github|azure

hal config security oauth2 edit \
  --client_id $CLIENT_ID
  --client_secret $CLIENT_SECRET
  --provider $PROVIDER
```

### Bring-Your-Own Provider

TODO(ttomsu): Update this for Halyard config

If you'd like to configure your own OAuth provider, you'll need to provide the following 
configuration values in your `gate-local.yml` file:

```yaml
spring:
  oauth2:
    client:
      clientId:
      clientSecret:
      userAuthorizationUri: # Used to get an authorization code
      accessTokenUri:       # Used to get an access token
      scope:
    resource:
      userInfoUri:          # Used to the current user's profile
    userInfoMapping:        # Used to map the userInfo response to our User
      email:
      firstName:
      lastName:
      username:
```

#### UserInfoMapping
The `userInfoMapping` field in the configuration is used to map the names of fields from the 
`userInfoUri` request to Spinnaker-specific fields. For example, if your user profile in your OAuth
 provider's system looks like:

```json
{
  "user": "fmercury",
  "mail": "fmercury@queen.com",
  "fName": "Freddie",
  "lName": "Mercury"
}
```

Then your `userInfoMapping` should look like:
```yaml
userInfoMapping:
  email: mail
  firstName: fName
  lastName: lName
  username: user
```

## Network Architecture and SSL Termination

During the OAuth [workflow](#workflow), Gate makes an intelligent guess on how to assemble a URI to
itself, called the **`redirect_uri`**. Sometimes this guess is wrong when Spinnaker is deployed 
in concert with other networking components, such as an SSL-terminating load balancer, or in the 
case of the [Quickstart](/setup/quickstart) images, a fronting Apache instance.

To manually set the `redirect_uri` Gate uses, set the following in your `halconfig`:

TODO(ttomsu): Update this when halyard supports this override.

```
spring:
  oauth2:
    client:
      preEstablishedRedirectUri: https://my-real-gate-address.com/login
      useCurrentUri: false
```


## Workflow

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
    [here](#network-architecture-and-ssl-termination) for how to fix this.
    
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
(`spring.oauth2.resource.userInfoUri`).

1. Gate uses the `userInfoMapping` to extract specific fields from the response, such as your 
username and email address, and associates it with the established session cookie with your user. 
See UserInfoMapping below.


The authorization code flow is the most secure way to get this data, because the _access token_ 
is never revealed outside of the server using it.

{% include mermaid %}

## Next Steps

Now that you've authenticated the user, proceed to setting up their [authorization](/setup/security/authorization/).

## Troubleshooting

* Review the general [authentication workflow](/setup/security/authentication#workflow).

* Use an [incognito window](/setup/security/authentication#incognito-mode).

* I'm getting an `Error: redirect_uri_mismatch` from my OAuth provider.

    The full error may look something like:
    
    > Error: redirect_uri_mismatch. The redirect URI in the request, https://some.url/login, 
    does not match the ones authorized for the OAuth client.
    
    This likely means you've not set up your OAuth credentials correctly. Ensure that the Authorized 
    Request URIs list contains "https://my-gate-address/login" (no trailing /).
