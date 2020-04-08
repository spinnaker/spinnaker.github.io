---
title:  "OAuth 2.0"
sidebar:
  nav: setup
---

{% include toc %}

OAuth 2.0 is the preferred way to authenticate and authorize third parties access to your data guarded
by the identity provider. To confirm your identity, Spinnaker requests access to your email address
from your identity provider.  Please read ALL of the documentation on this page as just setting the provider
may not work for your environment.


## OAuth providers

These OAuth 2.0 providers below have been pre-configured in Spinnaker. Follow the instructions to obtain a client ID 
and client secret.

* [Google Apps for Work / G Suite](./google/)
* [GitHub Teams](./github/)
* [Azure](./azure/)

### Pre-configured providers

For convenience, several providers are already pre-configured. As an administrator, you merely have
 to activate one, and give the client ID and secret. Follow the Provider-Specific documentation to
 obtain your client ID and client secret.

Provider | Halyard value | Provider-Specific Docs
--- | --- | ---
Google Apps for Work / G Suite | `google` | [Google Apps for Work / G Suite](./google/)
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

#### Enable your custom provider

Configure your custom OAuth Provider in Halyard

```
CLIENT_ID=myClientId
CLIENT_SECRET=myClientSecret

hal config security authn oauth2 edit \
  --client-id $CLIENT_ID \
  --client-secret $CLIENT_SECRET
```

Enable the oauth2 Provider in Halyard

```
hal config security authn oauth2 enable
```


## Network architecture and SSL termination

During the OAuth [workflow](/reference/architecture/authz_authn/authentication/#workflow), Gate makes an intelligent 
guess on how to assemble a URI to
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

* Review the general [authentication workflow](/reference/architecture/authz_authn/authentication/#workflow).

* Use an [incognito window](/setup/security/authentication#incognito-mode).

* I'm getting an `Error: redirect_uri_mismatch` from my OAuth provider.

    The full error may look something like:

    > Error: redirect_uri_mismatch. The redirect URI in the request, https://some.url/login,
    does not match the ones authorized for the OAuth client.

    This likely means you've not set up your OAuth credentials correctly. Ensure that the Authorized
    Request URIs list contains "https://my-gate-address/login" (no trailing /).
