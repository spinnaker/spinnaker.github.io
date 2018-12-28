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

It will produce the following items:
* `ca.crt` and `ca.key`, which are a `pem`-formatted certificate and private key used as a self-signed Certificate Authority.  The private key will have a password.

1. Create the CA key.  This will prompt for a password to encrypt the key.
   ```
   openssl genrsa -des3 -out ca.key 4096
   ```

1. Self-sign the CA certificate.  This will prompt for the password used to encrypt `ca.key`.
   ```
   openssl req -new -x509 -days 365 -key ca.key -out ca.crt
   ```

## 2. Create the server certificate(s)

If you have different DNS names for your Deck and Gate endpoints, you can either create a certificate with a CN and/or SAN that covers both DNS names, or you can create two certificates.  This document details creating these items, signed by the self-signed CA cert created above:

* `deck.crt` and `deck.key`, which are the `pem`-formatted certificate and private key for use by Deck.  The key will have a password.
* `gate.jks`, which is a Java KeyStore that contains the following:
  * The certificate and private key for use by Gate (with alias *gate*)
  * The certificate for the Certificate Authority created above (with alias *ca*)

1. Create a server key for Deck. Keep this file safe!
```
openssl genrsa -des3 -out deck.key 4096
```

1. Generate a certificate signing request for Deck. Specify `localhost` or Deck's eventual
fully-qualified domain name (FQDN) as the Common Name (CN).
```
openssl req -new -key deck.key -out deck.csr
```

1. Use the CA to sign the server's request and create the Deck server certificate (in `pem` format). If using an external CA, they will do this for you.
```
openssl x509 -req -days 365 -in deck.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out deck.crt
```

1. Create a server key for Gate. Keep this file safe!
```
openssl genrsa -des3 -out gate.key 4096
```

1. Generate a certificate signing request for Gate. Specify `localhost` or Gate's eventual
fully-qualified domain name (FQDN) as the Common Name (CN).
```
openssl req -new -key gate.key -out gate.csr
```

1. Use the CA to sign the server's request and create the Gate server certificate (in `pem` format). If using an external CA, they will do this for you.
```
openssl x509 -req -days 365 -in gate.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out gate.crt
```

1. Convert the `pem` format Gate server certificate into a PKCS12 file, which is importable into a Java Keystore (JKS).
```
YOUR_KEY_PASSWORD=hunter2
openssl pkcs12 -export -clcerts -in gate.crt -inkey gate.key -out gate.p12 -name gate -password pass:$YOUR_KEY_PASSWORD
```
This creates a p12 keystore file with your certificate imported under the alias "gate"
with the key password $YOUR_KEY_PASSWORD.

1. Create a Java Keystore containing the CA certificate
```
keytool -keystore gate.pks -import -trustcacerts -alias ca -file ca.crt
```

1. Import the Gate `p12`-formatted server certificate into your new keystore
```
$ keytool -importkeystore \
      -srckeystore gate.p12 \
      -srcstoretype pkcs12 \
      -srcalias gate \
      -srcstorepass $YOUR_KEY_PASSWORD \
      -destkeystore gate.pks \
      -deststoretype jks \
      -destalias gate \
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
KEYSTORE_PATH= # /path/to/gate.pks

hal config security api ssl edit \
  --key-alias gate \
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
SERVER_CERT=   # /path/to/deck.crt
SERVER_KEY=    # /path/to/deck.key

hal config security ui ssl edit \
  --ssl-certificate-file $SERVER_CERT \
  --ssl-certificate-key-file $SERVER_KEY \
  --ssl-certificate-passphrase

hal config security ui ssl enable
```

## 4. Deploy Spinnaker

```
hal deploy apply
```

## 5. Verify your SSL setup

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
