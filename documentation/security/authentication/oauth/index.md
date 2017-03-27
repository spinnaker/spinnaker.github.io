---
title:  "OAuth 2.0"
sidebar:
  nav: authentication
---

{% include toc %}

OAuth 2.0 is the preferred way authenticate and authorize third parties access to your data guarded by the identity provider. To confirm your identity, Spinnaker requests access to your email address from your identity provider.


The OAuth specification defines numerous flows for various scenarios. Spinnaker utilizes the _authorization code flow_, more commonly known as the three-legged OAuth.  The three-legged OAuth flow looks like:


1. User attempts to access a protected resource.

1. Gate redirects to OAuth provider, passing the following important bits:
    1. `client_id`: A pre-established identifier for this Gate instance.
    2. `redirect_uri`: Where to send the user after login. Must be accessible by the user's browser.
    3. `response_type=code`: Indicating that we are performing the three-legged OAuth flow.
    3. `scope`: What data or resources Gate would like access to. This is generally something like `email profile` to access the user's email address.

1. OAuth provider prompts user for username & password.

1. OAuth provider confirms that the user is granting Gate access to his profile.

1. Using the `redirect_uri`, the OAuth provider redirects the user to this address, providing an additional `code`
parameter.

1. Gate uses this `code` parameter to request an _access token_ from the OAuth provider's token server.

1. Gate uses the _access token_ to request user profile data from the resource server (`spring.oauth2.resource.userInfoUri`).

1. Gate uses the `userInfoMapping` to extract specific fields from the response, such as your username and email address, and associates it with the established session cookie with your user. See UserInfoMapping below.



The authorization code flow is the most secure way to get this data, because the _access token_ is never revealed outside of the server using it.

# OAuth Providers

## Pre-configured Providers

For convenience, several providers are already pre-configured. As an administrator, you merely have to activate one, and give the client ID and secret.

Provider | Profile | Config File | Provider-Specific Docs
--- | --- | ---
Google | `googleOAuth` | `/opt/spinnaker/config/gate-googleOAuth.yml` | [Google Apps](./google/)
GitHub | `githubOAuth` | `/opt/spinnaker/config/gate-githubOAuth.yml` | [GitHub Teams](./github/)
Azure | `azureOAuth` | `/opt/spinnaker/config/gate-azureOAuth.yml` | [Azure](./azure/)

Activate by setting the environmental variable `SPRING_PROFILES_ACTIVE=local,<profile>`

Create a config file at the location listed above with the contents:
```yaml
spring:
  oauth2:
    client:
      clientId: my-client-id
      clientSecret: ssshhh-its-a-sekret
```

## Bring-Your-Own Provider
If you'd like to configure your own OAuth provider, you'll need to provide the following configuration values in your `gate-local.yml` file:

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

### UserInfoMapping
The `userInfoMapping` field in the configuration is used to map the names of fields from the `userInfoUri` request to Spinnaker-specific fields. For example, if your user profile in your OAuth provider's system looks like:

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

# SSL Termination

Gate makes no assumption that it's being deployed in concert with other networking components, such as an SSL-terminating load balancer. Depending on your Spinnaker deployment, additional configuration may be necessary to get the authentication [dance](../../index.html) working properly.

* [Pre-built VM Images](./pre-built-images)
* [SSL Terminated at Server](./ssl-server-termination)
* [SSL Terminated at Load Balancer](./ssl-load-balancer-termination)
