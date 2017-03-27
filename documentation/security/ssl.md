---
title:  "SSL Setup"
sidebar:
  nav: security
---
{% include toc %}


This section will cover communication with parties external to your Spinnaker instance. That is, any requests between your browser and the Deck (the UI) host, between Deck and Gate (the API gateway), and between any other client and Gate.

## Network Architecture Options with SSL/TLS
It is strongly encouraged that your entire communication with all players is conducted over HTTPS. Most reasonable identity providers already run HTTPS-only, and you should look for a different solution provider if yours does not.

Each authentication mechanism is configured differently depending on where the SSL connection is terminated. Furthermore, the use of Spinnaker's all-in-one pre-built image adds a different configuration wrinkle when trying to add authentication.

Many users like to get authentication working before adding HTTPS, but experience bears out that the transition is not smooth. It is recommended to put at least a temporary SSL solution in place **first**.

## Certificate Authority

We will use `openssl` to generate a Certificate Authority (CA) and a server certificate. For the purposes of this tutorial, we'll use a self-signed CA. You may consider using an external CA to minimize browser configuration, but it's not necessary (and can be expensive).

Use the steps below to create a certificate authority. If you're using an external CA, skip to the next section.

1. Create the CA key.
```
openssl genrsa -des3 -out ca.key 4096
```
2. Self-sign the CA certificate.
```
openssl req -new -x509 -days 365 -key ca.key -out ca.crt
```

## Server Certificate
1. Create the server key. Keep this file safe!
```
openssl genrsa -des3 -out server.key 4096
```
2. Generate a certificate signing request for the server. Specify `localhost` or Gate's eventual fully-qualified domain name (FQDN) as the Common Name (CN).
```
openssl req -new -key server.key -out server.csr
```
3. Use the CA to sign the server's request. If using an external CA, they will do this for you.
```
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
```
4. Format server certificate into Java Keystore (JKS) importable form
```
openssl pkcs12 -export -clcerts -in server.crt -inkey server.key -out server.p12 -name spinnaker -password pass:$YOUR_KEY_PASSWORD
```
This will create a p12 keystore file with your certificate imported under the alias "spinnaker" with the key password $YOUR_KEY_PASSWORD.
5. Create Java Keystore by importing CA certificate
```
keytool -keystore keystore.jks -import -trustcacerts -alias ca -file ca.crt
```
6. Import server certificate
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

Voilà! You now have a Java Keystore with your certificate authority and server certificate ready to be used by Spinnaker!
