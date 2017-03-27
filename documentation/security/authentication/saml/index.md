---
title:  "SAML 2.0"
sidebar:
  nav: authentication
---

{% include toc %}


SAML is the time-tested authentication method that uses server-to-server Assertions to confirm user identity.

Because SAML is server-to-server, you must configure your Gate instance with a URL accessible by the SAML server.

## Identity Provider Configuration

Each SAML provider is a little bit different in how their service is exposed. The following configuration instructions have been tested against Ping, Okta, and Google Apps for Work.

1. Download (or obtain the URL to) the `metadata.xml` file from your Identity Provider. Make this file accessible to Gate, generally in `/opt/spinnaker/config/`. It may look something like:

    ```xml
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <md:EntityDescriptor
        xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
        entityID="https://accounts.google.com/o/saml2?idpid=SomeValueHere"
        validUntil="2021-05-16T15:17:27.000Z">
      <md:IDPSSODescriptor
          WantAuthnRequestsSigned="false"
          protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <md:KeyDescriptor use="signing">
          <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:X509Data>
              <ds:X509Certificate>MIIDdDCCAlygAwIBAgIGAVS/Sw5yMA0GCSqGSIb3DQEBCwUAMHsxFDASBgNVBAoTC0dvb2dsZSBJ
    bmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MQ8wDQYDVQQDEwZHb29nbGUxGDAWBgNVBAsTD0dv
    b2dsZSBGb3IgV29yazELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWEwHhcNMTYwNTE3
    MTUxNzI3WhcNMjEwNTE2MTUxNzI3WjB7MRQwEgYDVQQKEwtHb29nbGUgSW5jLjEWMBQGA1UEBxMN
    TW91bnRhaW4gVmlldzEPMA0GA1UEAxMGR29vZ2xlMRgwFgYDVQQLEw9Hb29nbGUgRm9yIFdvcmsx
    CzAJBgNVBAYTblVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMIIBIjANBgkqhkiG9w0BAQEF46OCAQ8A
    MIIBCgKCAQEA4JsnpS0ZBzb7DtlU7Zop7l+Kgr7NzusKWcEC6MOsFa4Dlt7jxv4ScKZ/61M5WKxd
    5YX0ol1rPokpNztj+Zk7OXrG8lDic0DpeDutc9pcq0+9/NYFF7WR7TDjh4B7Txnq7SerSB78fT8d
    4rK7Bd+cu/cBIyAAyZ5tLeLbmTnHAk093Y9vF3mdWQnfAhx4ldOfstF6G/d2ev7I5xjSKzQuH6Ew
    3bb3HLcM4uEVevOfNAlh1KoV4vQr+qzbc9UEFcPRwzuTwGa6QjfspWW7NgXKbHHC+X6a+gqJrke/
    6l2VvHaQBJ7oIyt4PCdel2cnUkvuxvzHPYedh1AgrIiSP1brSQIDAQABMA0GCSqGSI34DQEBCwUA
    A4IBAQCPqMAIau+pRDs2NZG1nGfyEMDfs0qop6FBa/wTNis75tLvay9MUlxXkTxm9aVxgggjEyc6
    XtDjpV0onrH0jBnSc+vRI1GFQ48EO3owy3uBIeR1aMy13ZwAA+KVizeoOrXBJbvIUZHo0yfKRzIu
    gtM58j58BdAFeYo+X9ds/ysvZ8FIGTLqMl/A3oO/yBNDjXR9Izoqgm7RX0JJXGL9Y1AgmEjxyqo9N
    MhxZAGxOHm9HZWWfVMcoe8p62mRJ2zf4lkNPBnDHrQ8MDPSsXewAuiSnRBDLxhdBgyThT/KW7Q06
    rGa6Dp0rntKWzZE3hGQS0AdsnuFY/OXbmkNG9WUrUg5x</ds:X509Certificate>
            </ds:X509Data>
          </ds:KeyInfo>
        </md:KeyDescriptor>
        <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
        <md:SingleSignOnService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            Location="https://accounts.google.com/o/saml2/idp?idpid=SomeValueHere"/>
        <md:SingleSignOnService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="https://accounts.google.com/o/saml2/idp?idpid=SomeValueHere"/>
      </md:IDPSSODescriptor>
    </md:EntityDescriptor>
    ```

1. Create a Spinnaker SAML application.
1. Specify the login URL as `https://gate.url:8084/saml/SSO`.
1. Specify a unique entity ID (we'll use `io.spinnaker:test` in our example).
1. Enable the users you'd like to have access to your Spinnaker instance.



## Gate Configuration

1. Generate a keystore and key in a new Java Keystore with some password:
```
keytool -genkey -v -keystore saml.jks -alias saml -keyalg RSA -keysize 2048 -validity 10000
```

1. Create or modify your `gate-local.yml` file to include the following settings:

```yaml
saml:
  enabled: true
  metadataUrl: file:/opt/spinnaker/config/metadata.xml # or URL to metadata file.
  keyStore: file:/opt/spinnaker/config/saml.jks
  keyStorePassword: $KEYSTORE_PASSWORD
  keyStoreAliasName: saml
  issuerId: io.spinnaker:test

  # These additional settings may be needed depending on if/where SSL is terminated.
  # See the documentation for your specific scenario.
  # The following are the default values:
  # redirectProtocol: "https"
  # redirectHostname: ${serverProperties.address.hostName}
  # redirectBasePath: "/"
```

# SSL Termination

Gate assumes it is being deployed with some form of SSL, but makes no assumption that it's being deployed in concert with other networking components, such as an SSL-terminating load balancer. Depending on your Spinnaker deployment, additional configuration may be necessary to get the authentication [dance](../../index.html) working properly.

* [Pre-built VM Images](./pre-built-images)
* [SSL Terminated at Server](./ssl-server-termination)
* [SSL Terminated at Load Balancer](./ssl-load-balancer-termination)
