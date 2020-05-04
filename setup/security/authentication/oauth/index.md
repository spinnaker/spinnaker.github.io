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

## Configuration

All of the OAuth 2.0 fields that can be configured in Halyard are detailed
[here](config.md). The documentation on this page frequently refers back to
these fields.

## OAuth 2.0 providers

In the general case, you’ll need to consult the documentation of your OAuth 2
provider to determine the appropriate values to put in each configurable field. For
some common OAuth 2.0 providers, specific documentation is provided here.

If you are using one of these providers, please follow the appropriate link
below for specific instructions on configuring your provider:
* [Azure](./azure/)
* [GitHub Teams](./github/)
* [Google Apps for Work / G Suite](./google/)
* [Oracle Cloud](./oracle/)

## Network architecture and SSL termination

During the OAuth [workflow](/reference/architecture/authz_authn/authentication/#workflow), Gate makes an intelligent 
guess on how to assemble a URI to
itself, called the *redirect URI*. Sometimes this guess is wrong when Spinnaker is deployed
in concert with other networking components, such as an SSL-terminating load balancer, or in the
case of the [Quickstart](/setup/quickstart) images, a fronting Apache instance.

You can manually set the redirect URI at the `security.authn.oauth2.client.preEstablishedRedirectUri`
field
```yaml
security:
  authn:
    oauth2:
      client:
        preEstablishedRedirectUri: https://my-real-gate-address.com:8084/login
```
or via the following `hal` command:
```bash
hal config security authn oauth2 edit --pre-established-redirect-uri https://my-real-gate-address.com:8084/login
```

> Be sure to include the `/login` suffix at the end of the of your `preEstablishedRedirectUri`!

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

## UserInfoMapping

The `userInfoMapping` field in the configuration is used to map the names of fields from the
`userInfoUri` request to Spinnaker-specific fields. For example, if your user profile in your OAuth 2.0
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

## Restricting access based on User Info

User access can be restricted further based on the user info from an OAuth ID token. This
requirement is set via the `security.authn.oauth2.userInfoRequirements` field, which
is a map of key/value pairs. The values are interpreted as regular expressions if
if they start and end with '/'. This enables us to restrict user login to specific
domains or users having a specific attribute.

For example:
```yaml
security:
  authn:
    oauth2:
      userInfoRequirements:
        hd: your-org.net
        batz: /^Sample.*Regex/
        foo: bar
```

To set this field with the Halylard CLI, use equal signs between key and value and
repeat the flag to specify multiple values:
```
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
