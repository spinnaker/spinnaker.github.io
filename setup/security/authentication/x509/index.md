---
title:  "X.509 Client Certificates"
sidebar:
  nav: setup
---

{% include toc %}

X.509 client certificates utilize the public-key infrastructure (PKI) in order to authenticate 
clients. X.509 can be used simultaneously with one of the other authentication methods, or by 
itself. Users commonly generate a certificate for their non-UI or script based clients, as this 
is generally easier than dynamically obtaining an OAuth Bearer token or SAML assertion.

## Certificates

If you followed the [SSL](../ssl/) guide, you may already have generated a **certificate 
authority**
(CA). Using this CA, we can generate a client certificate using `openssl`.

1. Create the client key. Keep this file safe!
    ```
    openssl genrsa -des3 -out client.key 4096
    ```

1. Generate a certificate signing request for the server.
    ```
    openssl req -new -key client.key -out client.csr
    ```

1. Use the CA to sign the server's request. If using an external CA, they will do this for you.
    ```
    openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt
    ```

1. (Optional) Format the client certificate into browser importable form.
    ```
    openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
    ```
    
## Configuration

TODO(ttomsu): Convert to hal commands when halyard supports X.509

The gist:

```yaml
x509:
  enabled: true
  subjectPrincipalRegex: EMAILADDRESS=(.*?)(?:,|$) # optional
  
server:
  ssl:
    enabled: true
    keyStore: /opt/spinnaker/config/keystore.jks
    keyStorePassword: hunter2
    keyAlias: server
    trustStore: /opt/spinnaker/config/keystore.jks
    trustStorePassword: hunter2
    
default:
  apiPort: 8083
```

### API Port

![browser's client certificate request](cert-auth.png)

By enabling X.509 on the main 8084 port, it causes the browser to ask the user to present their 
client certificate. Many end-users can get confused or annoyed by this message, so it is 
preferable by many to move this off of the main port. 

You can move the client certificate-enabled port by setting `default.apiPort` value to something 
other than 8084. This enables an additional port configuration that is 
[hardcoded](https://github.com/spinnaker/kork/blob/master/kork-web/src/main/groovy/com/netflix/spinnaker/config/TomcatConfiguration.groovy) 
to _need_ a valid X.509 certificate before allowing the request to proceed. 

## Workflow

Unlike the other authentication methods, X.509 does not have any redirects or fancy control 
passing between Deck, Gate, and a third-party identity provider. Connections are either 
established with a valid certificate or they're not.

## Next Steps

Now that you've authenticated the user, proceed to setting up their [authorization](/setup/security/authorization/).

## Troubleshooting

* Review the general [authentication workflow](/setup/security/authentication#workflow).

* Use an [incognito window](/setup/security/authentication#incognito-mode).
