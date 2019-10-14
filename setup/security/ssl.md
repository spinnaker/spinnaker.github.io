---
title:  "SSL"
sidebar:
  nav: setup
redirect_from: /setup/security/authentication/ssl

---
{% include toc %}


This section covers communication with Spinnaker from parties external to your
Spinnaker instance. That is, any requests between...

* your browser and the Spinnaker UI (Deck)

* Deck and Gate (the API gateway)

* any other client and Gate

## Network configurations

**Warning**: Many operators like to get authentication working before adding
HTTPS, but experience bears out that the transition is not smooth. We recommend
you implement at least a temporary SSL solution **first**.




## Load Balancer-terminated SSL

A common practice is to offload SSL-related bits to outside of the server in
question. This is fully supported in Spinnaker, but it does affect the
authentication configuration slightly. See your [authentication
method](/setup/security/authentication/) for specifics.

![SSL terminated at load balancer](/setup/security/authentication/network-arch/lb-ssl-termination.png)

During the certain authentication workflows, Gate makes an intelligent guess on how to assemble a URI to
itself, called the **`redirect_uri`**. Sometimes this guess is wrong when Spinnaker is deployed
in concert with other networking components, such as an SSL-terminating load balancer, or in the
case of the [Quickstart](/setup/quickstart) images, a fronting Apache instance.

To manually set the `redirect_uri` for Gate, use the following `hal` command:

```bash
hal config security authn <authtype> edit --pre-established-redirect-uri https://my-real-gate-address.com:8084/login
```

> Be sure to include the `/login` suffix at the end of the `--pre-established-redirect-uri` flag!

Additionally, some configurations make it necessary to "unwind" external proxy instances. This makes the request to 
Gate look like the original request to the outer-most proxy. Add this to your `gate-local.yml` file in your Halyard
[custom profile](/reference/halyard/custom/#custom-profiles):

```
server:
  tomcat:
    protocolHeader: X-Forwarded-Proto
    remoteIpHeader: X-Forwarded-For
    internalProxies: .*
```

## Server-terminated SSL

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


Terminating SSL within the Gate server is the de-facto way to enable SSL for
Spinnaker. This works with or without a load balancer proxying traffic to this
instance.  

![SSL terminated at server through load balancer](/setup/security/authentication/network-arch/server-ssl-termination.png)

#### 1. Generate key and self-signed certificate

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

#### 2. Create the server certificate(s)

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

#### 3. Configure SSL for Gate and Deck

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

#### 4. Deploy Spinnaker

```
hal deploy apply
```

## Verify your SSL setup

To verify that you've successfully set up SSL, try to reach one of the
endpoints, like Gate or Deck, over SSL.

## Troubleshooting

If you have problems...

* Are you using https?

* If you are running Spinnaker in a distributed environment, have you run
`hal deploy connect`?


## Using a custom CA for internal communications
There are a lot of places in Spinnaker which support the ability to configure custom Java trust/key stores for 
organizations who use internally signed certificates. In some cases, however, this isn’t supported yet but you still 
need to talk to a service which serves one of these certificates. This post will show you how to import your 
certificate into a Java trust/key store and configure a Spinnaker service with it.

Create a temporary copy of your system’s Java trust/key store and import your internal certificate. If you’re on a Mac,
this will be located at `/usr/libexec/java_home/)/jre/lib/security/cacerts`. It will be different on Linux.
```
mkdir /tmp/custom-trust-store`
cp {path-to-cacerts} /tmp/custom-trust-store
keytool import -alias custom-ca -keystore /tmp/custom-trust-store/cacerts -file {your-internal-certificate}
```

The below example instructions apply when use kubernetes to deploy spinnaker.  If not using spinnaker, you'll have 
to get the cacerts file updated as appropriate for your environment.  
```bash
kubectl create secret generic -n {your-spinnaker-namespace} internal-trust-store \
   --from-file /tmp/custom-trust-store/cacerts
```
Configure a Spinnaker service with the new trust/key store using a volume mount. In this example we’ll be configuring 
Front50 with this new store.

In `~/.hal/default/service-settings/front50.yml`
```
kubernetes:
  volumes:
  - id: internal-trust-store
    mountPath: /etc/ssl/certs/java
    type: secret
```

Redeploy Spinnaker using `hal deploy apply`.
The Spinnaker component for which you configured the volume mount should now be using the new trust/key store by 
default.

## Next steps

Choose an authentication method:

* [OAuth 2.0](/setup/security/authentication/oauth/)
* [SAML](/setup/security/authentication/saml/)
* [LDAP](/setup/security/authentication/ldap/)
* [X.509](/setup/security/authentication/x509/)
