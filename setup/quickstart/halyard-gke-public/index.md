---
layout: single
title:  "Try out public Spinnaker on GKE"
sidebar:
  nav: setup
---

{% include toc %}

If you've deployed Spinnaker already using [this
codelab](/setup/quickstart/halyard-gke) you're left with a Spinnaker that's
accessible only with `hal deploy connect`. This is unwieldy, making Spinnaker
difficult for other users in your organization to access.

In this codelab, we will focus on making Spinnaker accessible on a public
domain with OAuth2.0 enabled. There are other authentication methods supported,
and ways to configure your infrastructure to make Spinnaker reachable on a
private network - but those won't be covered here.

## Overview

At the end of this guide you will have

* Spinnaker's API server protected by OAuth2.0
* Spinnaker's API & UI servers fronted by public IP addresses
* Subdomains for Spinnaker's API & UI servers

## Part 0: Prerequisites

You need a [GAFW domain](https://admin.google.com) (referred to as `$DOMAIN`
for the remainder of this tutorial).

You need a running Spinnaker cluster in GKE. If you don't have one, please go
through [this codelab](/setup/quickstart/halyard-gke).

## Part 1: Configuring Authentication

Before we expose Spinnaker on a public IP address, we want to make sure that no
unauthenticated user can access Spinnaker.

First, navigate to the [Google credentials
manager](https://console.developers.google.com/apis/credentials), and create a
new set of credentials:

{% include figure
   image_path="./oauth-id.png"
   alt="image of oauth id creation"
%}

Next, fill out the following fields, and hit "Create":

{% include figure
   image_path="./create-client-id.png"
   alt="image of oauth id form"
   caption="The use of `localhost:8084` is intentional for now. We will
   revisit this once we expose the Spinnaker endpoints."
%}

You will be greeted with the following screen with values for `$CLIENT_ID` and
`$CLIENT_SECRET`:

{% include figure
   image_path="./oauth-secrets.png"
   alt="image of secrets"
   caption="Keep these values safe!"
%}

With those secrets, run the following hal commands

```bash
hal config security authn oauth2 edit --provider google \
    --client-id $CLIENT_ID \
    --client-secret $CLIENT_SECRET \
    --user-info-requirements hd=$DOMAIN

hal config security authn oauth2 enable
```

> :warning: The `--user-info-requirements hd=$DOMAIN` is __very__ important.
> Without it, any user with a valid GMail address can sign into your Spinnaker.

At this point, you're ready to see if your authentication configuration
works. To do so, we need to apply your configuration changes:

```bash
hal deploy apply

# wait for services to come up...

hal deploy connect
```

If you're greeted with the following login screen on
[localhost:9000](http://localhost:9000) you're all set! Make sure you can
successfully login before continuing, however.

{% include figure
   image_path="./google-sign-in.png"
   alt="image of sign in screen"
%}

## Part 2: Creating Public Spinnaker Endpoints

Next we will expose Spinnaker on endpoints discoverable via DNS. Given that we
have our domain `$DOMAIN`, we will add subdomains for `spinnaker.$DOMAIN`
and `spinnaker-api.$DOMAIN` for the UI & API servers respectively.

First we need IP addresses for our public services. Navigate to the [external IP
address configuration](https://console.cloud.google.com/networking/addresses)
for your GCP project, and fill out this screen and hit "Reserve" __two times__.

{% include figure
   image_path="./reserve-ip.png"
   alt="image showing reserve ip screen"
   caption="The name is not important; however, the region __must__ match that
   of your GKE cluster. Remember to reserve __two__ IP addresses."
%}

Once completed, you will see the reserved, static IP addresses with values for
`$API_ADDRESS` and `$UI_ADDRESS`:

{% include figure
   image_path="./reserved-ips.png"
   alt="image showing reserved ips"
%}

Now head to your [domain configuration](https://domains.google.com), and add A
records for both IP addresses, and fill out this form twice as shown,
subsituting for your values of `$API_ADDRESS` and `$UI_ADDRESS`:

{% include figure
   image_path="./spinnaker-subdomain.png"
   alt="image showing spinnaker subdomain"
%}

{% include figure
   image_path="./spinnaker-api-subdomain.png"
   alt="image showing spinnaker api subdomain"
%}

Once your resource records have been recorded, we need to configure Spinnaker
and your Google credentials to accept logins from these domains.

First navigate back to the [Google credentials
manager](https://console.developers.google.com/apis/credentials), and edit the
Spinnaker client ID using your value of `$DOMAIN`:

{% include figure
   image_path="./edit-id.png"
   alt="image showing client id edit link"
%}

{% include figure
   image_path="./new-redirect.png"
   alt="image showing updated redirect url"
%}

Now authorize the UI and API servers to receive requests at these urls using
Halyard:

```bash
hal config security ui edit \
    --override-base-url http://spinnaker.$DOMAIN

hal config security api edit \
    --override-base-url http://spinnaker-api.$DOMAIN
```

Now, before we finalize these changes by deploying Spinnaker, we need to edit
the [Kubernetes
Services](https://kubernetes.io/docs/concepts/services-networking/service/)
fronting the UI & API servers, `spin-deck` and `spin-gate` in the `spinnaker`
namespace respectively.

> __NOTE__: Halyard will __not__ make any changes to these services once they
> are created, so you are welcome to make whatever changes necessary and have
> them persist.

Run the following command

```bash
kubectl edit svc spin-deck -n spinnaker
```

You will have the service definition open in your text editor. Make the changes
noted below (change `port: ` to 80, `type: ` to "LoadBalancer", and add
`loadBalancerIP: `):

```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2017-06-01T00:57:34Z
  name: spin-deck
  namespace: spinnaker
  resourceVersion: "6038615"
  selfLink: /api/v1/namespaces/spinnaker/services/spin-deck
  uid: 4c1fb82f-4165-11e7-888f-42020a8a0a12
spec:
  clusterIP: 10.127.244.30
  ports:
  - port: 80                           ## CHANGE THIS TO 80
    protocol: TCP
    targetPort: 9000
  selector:
    load-balancer-spin-deck: "true"
  sessionAffinity: None
  type: LoadBalancer                   ## CHANGE FROM ClusterIP to LoadBalancer
  loadBalancerIP: $UI_ADDRESS          ## ADD THIS LINE FOR YOUR VALUE OF
                                       ## $UI_ADDRESS
status:
  loadBalancer: {}
```

Now repeat this but for `spin-gate` and `$API_ADDRESS` as shown here:

```bash
kubectl edit svc spin-gate -n spinnaker
```

You will have the service definition open in your text editor. Make the changes
noted below (change `port: ` to 80, `type: ` to "LoadBalancer", and add
`loadBalancerIP: `):

```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2017-06-01T00:57:32Z
  name: spin-gate
  namespace: spinnaker
  resourceVersion: "6038615"
  selfLink: /api/v1/namespaces/spinnaker/services/spin-gate
  uid: 1c4fd288-818a-166e-888f-45251eee0d92
spec:
  clusterIP: 10.127.244.29
  ports:
  - port: 80                           ## CHANGE THIS TO 80
    protocol: TCP
    targetPort: 8084
  selector:
    load-balancer-spin-gate: "true"
  sessionAffinity: None
  type: LoadBalancer                   ## CHANGE FROM ClusterIP to LoadBalancer
  loadBalancerIP: $API_ADDRESS         ## ADD THIS LINE FOR YOUR VALUE OF
                                       ## $API_ADDRESS
status:
  loadBalancer: {}
```

Finally, redeploy Spinnaker:

```
hal deploy apply
```

And navigate to `spinnaker.$DOMAIN` in your browser.

> __NOTE__: It can take some time for the DNS entries to propagate, so be
> patient if you can't access the Spinnaker UI immediately.

