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

Each private key, and several other of the sensitive files generated in this doc
will have a password/passphrase.  These are the password/passphrases bash variables 
used in this doc (please substitute your own passwords/passphrases):

```bash
CA_KEY_PASSWORD=SOME_PASSWORD_FOR_CA_KEY
DECK_KEY_PASSWORD=SOME_PASSWORD_FOR_DECK_KEY
GATE_KEY_PASSWORD=SOME_PASSWORD_FOR_GATE_KEY
JKS_PASSWORD=SOME_JKS_PASSWORD
GATE_EXPORT_PASSWORD=SOME_PASSWORD_FOR_GATE_P12
```

In addition, in many of the calls below, if you want `openssl` or `keytool` to prompt
for the key rather than providing them via the CLI, you can just remove the relevant flag.

## 1. Generate key and self-signed certificate

We will use `openssl` to generate a Certificate Authority (CA) key and a server
certificate. These instructions create a self-signed CA. You might want to
use an external CA, to minimize browser configuration, but it's not necessary
(and can be expensive).

Use the steps below to create a certificate authority. (If you're using an
external CA, skip to the next section.)

It will produce the following items:

* `ca.key`: a `pem`-formatted private key, which will have a pass phrase.
* `ca.crt`: a `pem`-formatted certificate, which (with the private key) acts as
a self-signed Certificate Authority.

1. Create the CA key.  This will prompt for a pass phrase to encrypt the key.

    ```bash
    openssl genrsa \
      -des3 \
      -out ca.key \
      -passout pass:${CA_KEY_PASSWORD} \
      4096
    ```

1. Self-sign the CA certificate.  This will prompt for the pass phrase used to 
encrypt `ca.key`.

    ```bash
    openssl req \
      -new \
      -x509 \
      -days 365 \
      -key ca.key \
      -out ca.crt \
      -passin pass:${CA_KEY_PASSWORD}
    ```

## 2. Create the server certificate(s)

If you have different DNS names for your Deck and Gate endpoints, you can either
create a certificate with a CN and/or SAN that covers both DNS names, or you can
create two certificates.  This document details creating these items, signed by
the self-signed CA cert created above:

* `deck.key`: a `pem`-formatted private key, which will have a pass phrase.
* `deck.crt`: a `pem`-formatted certificate, which (with the private key) serves
as the server certificate used by Deck.
* `gate.jks`: a Java KeyStore (JKS) that contains the following:
  * The certificate and private key for use by Gate (with alias *gate*)
  * The certificate for the Certificate Authority created above (with alias *ca*)

Additionally, these intermediate files will be created:

* `deck.csr`: a Certificate Signing Request file, generated from `deck.key` and
used in conjunction with `ca.key` to sign `deck.crt`
* `gate.csr`: a Certificate Signing Request file, generated from `gate.key` and
used in conjunction with `ca.key` to sign `gate.crt`
* `gate.crt`: a `pem`-formatted certificate for Gate.  This will be converted to
.p12 and imported into the JKS.
* `gate.p12`: a `p12`-formatted certificate and private key for Gate.  This will
be imported into the JKS.

1. Create a server key for Deck. Keep this file safe!

    This will prompt for a pass phrase to encrypt the key.

    ```bash
    openssl genrsa \
      -des3 \
      -out deck.key \
      -passout pass:${DECK_KEY_PASSWORD} \
      4096
    ```

1. Generate a certificate signing request (CSR) for Deck. Specify `localhost` or
Deck's eventual fully-qualified domain name (FQDN) as the Common Name (CN).  

    This will prompt for the pass phrase for `deck.key`.

    ```bash
    openssl req \
      -new \
      -key deck.key \
      -out deck.csr \
      -passin pass:${DECK_KEY_PASSWORD}
    ```

1. Use the CA to sign the server's request and create the Deck server certificate
(in `pem` format). If using an external CA, they will do this for you.  

    This will prompt for the pass phrase used to encrypt `ca.key`.

    ```bash
    openssl x509 \
      -req \
      -days 365 \
      -in deck.csr \
      -CA ca.crt \
      -CAkey ca.key \
      -CAcreateserial \
      -out deck.crt \
      -passin pass:${CA_KEY_PASSWORD}
    ```

1. Create a server key for Gate. This will prompt for a pass phrase to encrypt 
the key. Keep this file safe!

    ```bash
    openssl genrsa \
      -des3 \
      -out gate.key \
      -passout pass:${GATE_KEY_PASSWORD} \
      4096
    ```

1. Generate a certificate signing request for Gate. Specify `localhost` or Gate's
eventual fully-qualified domain name (FQDN) as the Common Name (CN).  

    This will prompt for the pass phrase for `gate.key`.

    ```bash
    openssl req \
      -new \
      -key gate.key \
      -out gate.csr \
      -passin pass:${GATE_KEY_PASSWORD}
    ```

1. Use the CA to sign the server's request and create the Gate server certificate
(in `pem` format).  If using an external CA, they will do this for you.  

    This will prompt for the pass phrase used to encrypt `ca.key`.

    ```bash
    openssl x509 \
      -req \
      -days 365 \
      -in gate.csr \
      -CA ca.crt \
      -CAkey ca.key \
      -CAcreateserial \
      -out gate.crt \
      -passin pass:${CA_KEY_PASSWORD}
    ```

1. Convert the `pem` format Gate server certificate into a PKCS12 (`p12`) file,
which is importable into a Java Keystore (JKS).  

    This will first prompt for the pass phrase used to encrypt `gate.key`, and
    then for an import/export password to use to encrypt the `p12` file.

    ```bash
    openssl pkcs12 \
      -export \
      -clcerts \
      -in gate.crt \
      -inkey gate.key \
      -out gate.p12 \
      -name gate \
      -passin pass:${GATE_KEY_PASSWORD} \
      -password pass:${GATE_EXPORT_PASSWORD}
    ```

    This creates a p12 keystore file with your certificate imported under the alias "gate".

1. Create a new Java Keystore (JKS) containing your `p12`-formatted Gate server certificate.


    Because Gate assumes that the keystore password and the password for the key
    in the keystore are the same, we must provide both via the command line.
    This will prompt for the import/export password used to encrypt the `p12` file.

    ```bash
    keytool -importkeystore \
      -srckeystore gate.p12 \
      -srcstoretype pkcs12 \
      -srcalias gate \
      -destkeystore gate.jks \
      -destalias gate \
      -deststoretype pkcs12 \
      -deststorepass ${JKS_PASSWORD} \
      -destkeypass ${JKS_PASSWORD} \
      -srcstorepass ${GATE_EXPORT_PASSWORD}
    ```

1. Import the CA certificate into the Java Keystore.  
    
    This will prompt for a password to encrypt the Keystore file.

    ```bash
    keytool -importcert \
      -keystore gate.jks \
      -alias ca \
      -file ca.crt \
      -storepass ${JKS_PASSWORD} \
      -noprompt
    ```

1. Verify the Java Keystore contains the correct contents.

    ```bash
    keytool \
      -list \
      -keystore gate.jks \
      -storepass ${JKS_PASSWORD}
    ```

    It should contain two entries:

    * `gate` as a `PrivateKeyEntry`
    * `ca` as a `trustedCertEntry`

Voilà! You now have a Java Keystore with your certificate authority and server
certificate ready to be used by Spinnaker Gate, and, separately, a pem-formatted
key and server certificate ready to be used by Spinnaker Deck!

## 3. Configure SSL for Gate and Deck

With the above certificates and keys in hand, you can use Halyard to set up SSL
for [Gate and Deck](/reference/architecture/).

For Gate:

*This will prompt twice, once for the keystore password and once for the truststore
password, which are the same.*

```bash
KEYSTORE_PATH= # /path/to/gate.jks

hal config security api ssl edit \
  --key-alias gate \
  --keystore ${KEYSTORE_PATH} \
  --keystore-password \
  --keystore-type jks \
  --truststore ${KEYSTORE_PATH} \
  --truststore-password \
  --truststore-type jks

hal config security api ssl enable
```

For Deck:

*This will prompt for the pass phrase used to encrypt `deck.crt`.*

```bash
SERVER_CERT=   # /path/to/deck.crt
SERVER_KEY=    # /path/to/deck.key

hal config security ui ssl edit \
  --ssl-certificate-file ${SERVER_CERT} \
  --ssl-certificate-key-file ${SERVER_KEY} \
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
