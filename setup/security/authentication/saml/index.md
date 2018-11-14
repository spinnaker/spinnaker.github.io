---
title:  "SAML 2.0"
sidebar:
  nav: setup
redirect_from: /docs/gate-saml-config
---

{% include toc %}

Security Assertion Markup Language (SAML) is an XML based way to implement single sign-on (SSO). 

A cryptographically signed XML document (known as a "SAML Assertion") is sent to the API gateway server (Gate) with 
your identifying information, such as username and group membership. 

Gate verifies the XML document's signature using a `metadata` file, and if successful, it associates the 
identifying information with the user and allows the user to proceed as authenticated.

## Identity provider setup

1. In your SAML Identity Provider (IdP), download the `metadata.xml` file. Some providers expose this as a URL. It 
may look something like this:
    
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
              <ds:X509Certificate>
    MIIDdDCCAlygAwIBAgIGAVS/Sw5yMA0GCSqGSIb3DQEBCwUAMHsxFDASBgNVBAoTC0dvb2dsZSBJ
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
    gtM58j58BdAFeYo+X9ds/ysvZ8FIGTLqMl/A3oO/yBNDjXR9Izoqgm7RX0JJXGL9Y1AgmEjxyqo9
    MhxZAGxOHm9HZWWfVMcoe8p62mRJ2zf4lkNPBnDHrQ8MDPSsXewAuiSnRBDLxhdBgyThT/KW7Q06
    rGa6Dp0rntKWzZE3hGQS0AdsnuFY/OXbmkNG9WUrUg5x
              </ds:X509Certificate>
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
1. Specify the login URL as `https://localhost:8084/saml/SSO`. Replace "localhost" with Gate's address, if known.
1. Specify a unique entity ID (we'll use `spinnaker.test` in our example).
1. Enable the users you'd like to have access to your Spinnaker instance.

1. Generate a keystore and key in a new Java Keystore with some password:
    ```
    keytool -genkey -v -keystore saml.jks -alias saml -keyalg RSA -keysize 2048 -validity 10000
    ```
1. Execute the following halyard commands and redeploy Gate:

    ```
    KEYSTORE_PATH= # /path/to/keystore.jks
    KEYSTORE_PASSWORD=hunter2
    METADATA_PATH= # /path/to/metadata.xml
    SERVICE_ADDR_URL=https://localhost:8084
    ISSUER_ID=spinnaker.test
    
    hal config security authn saml edit \
      --keystore $KEYSTORE_PATH \
      --keystore-alias saml \
      --keystore-password $KEYSTORE_PASSWORD \
      --metadata $METADATA_PATH \
      --issuer-id $ISSUER_ID \
      --service-address-url $SERVICE_ADDR_URL
      
    hal config security authn saml enable
    ```

## Network architecture and SSL termination

During the SAML [workflow](#workflow), Gate makes an intelligent guess on how to assemble a URI to itself, called the
_Assertion Consumer Service URL_. Sometimes this guess is wrong when Spinnaker is deployed in concert with other 
networking components, such as an SSL-terminating load balancer, or in the case of the [Quickstart](/setup/quickstart)
images, a fronting Apache instance.

To override the values to assemble the URL, use the following `hal` command:


```bash
hal config security authn saml edit --service-address-url https://my-real-gate-address.com:8084
```

> For the Quickstart images, append `/gate` to the `--service-address-url. All other configurations
can omit this setting.

## Workflow
The SAML workflow below reflects the process when the user navigates to _Spinnaker first_, is redirected to the SAML 
IdP for login, and redirected back to Spinnaker. Some SAML providers will allow the user login to the _SAML provider 
first_, and click a link to be taken to Spinnaker.


<div class="mermaid">
    sequenceDiagram
    
    participant Deck
    participant Gate
    participant IdentityProvider
    
    Deck->>+Gate: GET /something/protected
    Gate->>-Deck: HTTP 302 to https://idp.url/?SAMLRequest=...
    
    Deck->>+IdentityProvider: GET https://idp.url/?SAMLRequest=...
    IdentityProvider->>-Deck: Returns login page
</div>

1. User attempts to access a protected resource.

1. Gate redirects to the SAML provider, passing a few query params:
    * `SAMLRequest`: a Gzip'ed XML authentication request.
    * `SigAlg`: The algorithm used to generate the `Signature` parameter.
    * `Signature`: A digest of the `SAMLRequest` using the `SigAlg` algorithm and the server's key.

    > Within the `SAMLRequest` is the _Assertion Consumer Service URL_, with is the URL to your Gate instance. See 
    [here](#network-architecture-and-ssl-termination) for how to override this value.
    
1. SAML provider prompts user for username & password.
    <div class="mermaid">
        sequenceDiagram
        
        participant Deck
        participant Gate
        participant IdentityProvider
        
        Deck->>+IdentityProvider: User sends credentials
        IdentityProvider->>-Deck: HTTP 200 with self-submitting form to POST https://gate.url
        Deck->>+Gate: POST /saml/SSO with { SAMLResponse: ... }
        Note right of Gate: User identity verified
        Note right of Gate: Gate extracts data based on userInfoMapping
        Gate->>-Deck: HTTP 302 /something/protected
    </div>

1. A SAML response must be POSTed to `/saml/SSO`, and most browsers won't re-POST when given an HTTP 302. Instead, 
providers sometimes return a page (with HTTP 200) that has a self-submitting HTML form to POST to Gate's `/saml/SSO` 
endpoint.

1. Gate verifies the message's integrity by checking its signature, and thus verifying the user's identity information.

1. Gate determines the username and/or email address, and optionally extracts group membership (if sent by the IdP).

1. With the user's identity verified, Gate redirects the user to the originally requested URL.

{% include mermaid %}

## Next steps

Now that you've authenticated the user, proceed to setting up their [authorization](/setup/security/authorization/).

## Troubleshooting

* Review the general [authentication workflow](/setup/security/authentication#workflow).

* Use an [incognito window](/setup/security/authentication#incognito-mode).

