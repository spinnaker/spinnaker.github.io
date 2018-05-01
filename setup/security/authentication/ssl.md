---
title:  "SSL"
sidebar:
  nav: setup
---
{% include toc %}


This section covers communication with Spinnaker from parties external to your
Spinnaker instance. That is, any requests between...

* your browser and the Spinnaker UI (Deck)

* Deck and Gate (the API gateway)

* any other client and Gate

> **Info**: Many operators like to get authentication working before adding
HTTPS, but experience bears out that the transition is not smooth. We recommend
you implement at least a temporary SSL solution **first**.

## 1. Generate key and self-signed certificate

We will use `openssl` to generate a Certificate Authority (CA) key and a server
certificate. These instructions create a self-signed CA. You might want to
use an external CA, to minimize browser configuration, but it's not necessary
(and can be expensive).

Use the steps below to create a certificate authority. (If you're using an
external CA, skip to the next section.)

1. Create the CA key.
   ```
   openssl genrsa -des3 -out ca.key 4096
   ```

1. Self-sign the CA certificate.
   ```
   openssl req -new -x509 -days 365 -key ca.key -out ca.crt
   ```

## 2. Create the server certificate

Use the self-signed CA cert you created above to sign the server certificate.

1. Create the server key. Keep this file safe!
```
openssl genrsa -des3 -out server.key 4096
```

1. Generate a certificate signing request for the server. Specify `localhost` or Gate's eventual
fully-qualified domain name (FQDN) as the Common Name (CN).
```
openssl req -new -key server.key -out server.csr
```

1. Use the CA to sign the server's request. If using an external CA, they will do this for you.
```
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
```

1. Format server certificate into Java Keystore (JKS) importable form.
```
YOUR_KEY_PASSWORD=hunter2
openssl pkcs12 -export -clcerts -in server.crt -inkey server.key -out server.p12 -name spinnaker -password pass:$YOUR_KEY_PASSWORD
```
This creates a p12 keystore file with your certificate imported under the alias "spinnaker"
with the key password $YOUR_KEY_PASSWORD.

1. Create Java Keystore by importing CA certificate
```
keytool -keystore keystore.jks -import -trustcacerts -alias ca -file ca.crt
```

1. Import server certificate
```
$ keytool -importkeystore \
      -srckeystore server.p12 \
      -srcstoretype pkcs12 \
      -srcalias spinnaker \
      -srcstorepass $YOUR_KEY_PASSWORD \
      -destkeystore keystore.jks \
      -deststoretype jks \
      -destalias spinnaker \
      -deststorepass $YOUR_KEY_PASSWORD \
      -destkeypass $YOUR_KEY_PASSWORD
```

Voilà! You now have a Java Keystore with your certificate authority and server certificate ready to
be used by Spinnaker!


## 3. Configure SSL for Gate and Deck

With the above certificates and keys in hand, you can use Halyard to set up SSL
for [Gate and Deck](/reference/architecture/).

For Gate:

```bash
KEYSTORE_PATH= # /path/to/keystore.jks

hal config security api ssl edit \
  --key-alias spinnaker \
  --keystore $KEYSTORE_PATH \
  --keystore-password \
  --keystore-type jks \
  --truststore $KEYSTORE_PATH \
  --truststore-password \
  --truststore-type jks

hal config security api ssl enable
```

For Deck:

```bash
SERVER_CERT=   # /path/to/server.crt
SERVER_KEY=    # /path/to/server.key

hal config security ui ssl edit \
  --ssl-certificate-file $SERVER_CERT \
  --ssl-certificate-key-file $SERVER_KEY \
  --ssl-certificate-passphrase

hal config security ui ssl enable
```
## 4. Verify your SSL setup

To verify that you've successfully set up SSL, try to reach one of the
endpoints, like Gate or Deck, over SSL.

## Troubleshooting

If you have problems...

* Are you using https?

* If you are running Spinnaker in a distributed environment, have you run
`hal deploy connect`?

## About network configurations

Each authentication mechanism is configured differently depending on where the
SSL connection terminates.

### Server-terminated SSL

Terminating SSL within the Gate server is the de-facto way to enable SSL for
Spinnaker. This works with or without a load balancer proxying traffic to this
instance.

![SSL terminated at server through load balancer](/setup/security/authentication/network-arch/server-ssl-termination.png)

### Load Balancer-terminated SSL

A common practice is to offload SSL-related bits to outside of the server in
question. This is fully supported in Spinnaker, but it does affect the
authentication configuration slightly. See your [authentication
method](/setup/security/authentication/) for specifics.

![SSL terminated at load balancer](/setup/security/authentication/network-arch/lb-ssl-termination.png)

## Next steps

Choose an authentication method:

* [OAuth 2.0](/setup/security/authentication/oauth/)
* [SAML](/setup/security/authentication/saml/)
* [LDAP](/setup/security/authentication/ldap/)
* [X.509](/setup/security/authentication/x509/)
