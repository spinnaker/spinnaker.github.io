---
title:  "OAuth 2.0"
sidebar:
  nav: setup
---

{% include toc %}

OAuth 2.0 is the preferred way to authenticate and authorize third parties access to your data guarded
by the identity provider. To confirm your identity, Spinnaker requests access to your email address
from your identity provider.


## OAuth providers

### Pre-configured providers

For convenience, several providers are already pre-configured. As an administrator, you merely have
 to activate one, and give the client ID and secret. Follow the Provider-Specific documentation to
 obtain your client ID and client secret.

Provider | Halyard value | Provider-Specific Docs
--- | --- | ---
Google Apps for Work / G Suite | `google` | [Google Apps for Work / G Suite](./providers/google/)
GitHub | `github` | [GitHub Teams](https://help.github.com/articles/authorizing-oauth-apps/){:target="\_blank"}
Azure | `azure` | [Azure](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-oauth-code){:target="\_blank"}

Activate one by executing the following:

```
CLIENT_ID=myClientId
CLIENT_SECRET=myClientSecret
PROVIDER=google|github|azure

hal config security authn oauth2 edit \
  --client-id $CLIENT_ID \
  --client-secret $CLIENT_SECRET \
  --provider $PROVIDER
hal config security authn oauth2 enable
```

### Bring-your-own provider

If you'd like to configure your own OAuth provider, you'll need to provide the following
configuration values in your `gate-local.yml` file. If you're using Halyard, you can put this in
a new file under your [deployment](/reference/halyard/#deployments) (typically `default`):
`~/.hal/$DEPLOYMENT/profiles/gate-local.yml`.

```yaml
security:
  oauth2:
    client:
      clientId:
      clientSecret:
      userAuthorizationUri: # Used to get an authorization code
      accessTokenUri:       # Used to get an access token
      scope:
    resource:
      userInfoUri:          # Used to get the current user's email address/profile
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

## Network architecture and SSL termination

During the OAuth [workflow](#workflow), Gate makes an intelligent guess on how to assemble a URI to
itself, called the **`redirect_uri`**. Sometimes this guess is wrong when Spinnaker is deployed
in concert with other networking components, such as an SSL-terminating load balancer, or in the
case of the [Quickstart](/setup/quickstart) images, a fronting Apache instance.

To manually set the `redirect_uri` for Gate, use the following `hal` command:

```bash
hal config security authn oauth2 edit --pre-established-redirect-uri https://my-real-gate-address.com:8084/login
```

> Be sure to include the `/login` suffix at the end of the `--pre-established-redirect-uri` flag!

Additionally, some configurations make it necessary to "unwind" external proxy instances. This makes the request to Gate
look like the original request to the outer-most proxy. Add this to your `gate-local.yml` file in your Halyard
[custom profile](/reference/halyard/custom/#custom-profiles):

```
server:
  tomcat:
    protocolHeader: X-Forwarded-Proto
    remoteIpHeader: X-Forwarded-For
    internalProxies: .*
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
(`security.oauth2.resource.userInfoUri`).

1. Gate uses the `userInfoMapping` to extract specific fields from the response, such as your
username and email address, and associates it with the established session cookie with your user.
See UserInfoMapping below.


The authorization code flow is the most secure way to get this data, because the _access token_
is never revealed outside of the server using it.

{% include mermaid %}

## Restricting access based on User Info

User access can be restricted further based on the user info from an OAuth ID token. This
requirement is set via the `--user-info-requirements` parameter. This enables us to restrict user
login to specific domains or having a specific attribute. Use equal signs between key and value,
and additional key/value pairs need to repeat the flag. The values can also be regex expressions
if they start and end with '/'.
```
# Example:
hal config security authn oauth2 edit \
  --user-info-requirements hd=your-org.net \
  --user-info-requirements batz=/^Sample.*Regex/ \
  --user-info-requirements foo=bar
```

## Next steps

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
