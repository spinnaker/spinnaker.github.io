---
layout: single
title:  "Docker Registry"
sidebar:
  nav: setup
redirect_from: /setup/providers/docker-registry/
---

{% include toc %}

> :warning: This only acts as a source of images, and does not include support
> for deploying Docker images.

When configuring Docker Registries, an
[__Account__](/concepts/providers/#accounts) maps to a credential able to
authenticate against a certain set of [Docker
repositories](https://docs.docker.com/glossary/?term=repository){:target="\_blank"}.

Perform the steps in this article in the same place where you have Halyard
installed, whether [in a Docker
container](/setup/install/halyard/#install-halyard-on-docker) or [locally on
Ubuntu/Debian or macOS](/setup/install/halyard/#update-halyard-on-debianubuntu-or-macos).

## Prerequisites

* The Docker Registry you are configuring must already exist.
* That Registry must support the
[v2 registry API](https://docs.docker.com/registry/spec/api/){:target="\_blank"}.
* If the Registry doesn't have at least 1
[tag](https://docs.docker.com/glossary/?term=tag){:target="\_blank"} among the
repositories you define in your Account, Halyard throws a warning.

## Registry providers

You can set up a Docker Registry provider for Spinnaker using any of the
repositories listed here. Each one supports the same API, but there
are subtle differences in how to get them to work with Spinnaker.

* [DockerHub](#dockerhub)
* [Google Container Registry](#google-container-registry)
* [Amazon Elastic Container Registry (ECR)](#amazon-elastic-container-registry-ecr)
* [Other Registries](#other-registries)

### DockerHub

The DockerHub registry address is `index.docker.io`, keep track of this for
later:

```bash
ADDRESS=index.docker.io
```

Dockerhub hosts a mix of public and private repositories, but does not expose a
[catalog](https://docs.docker.com/registry/spec/api/#listing-repositories){:target="\_blank"}
endpoint to programmatically list them. Therefore you need to explicitly list
which Docker repositories you want to index and deploy. For example, if you
wanted to deploy the public NGINX image, alongside your private `app` image,
your list of repositories would look like:

```bash
REPOSITORIES=library/nginx yourusername/app
```

> __NOTE__: Keep in mind that the repository name is typically either prefixed
> with `library/` for most public images, or `<username>/` for images belonging
> to user `<username>/`.

If any of your images aren't publicly available, make sure you know your
DockerHub username & password to supply to `hal` later:

```bash
USERNAME=yourusername
PASSWORD=hunter2
```

### Google Container Registry

1. Set the registry address.

   There are a few different registry addresses for GCR, depending on where you
   want to store your images. The most likely address is `gcr.io`, but there are
   [more options available](https://cloud.google.com/container-registry/docs/pushing#pushing_to_the_registry){:target="\_blank"}.

   ```bash
   ADDRESS=gcr.io
   ```

1. (Optional) Enable the [Resource Manager
API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview){:target="\_blank"}.

   Enable this API if you want to use the
   [catalog](https://docs.docker.com/registry/spec/api/#listing-repositories){:target="\_blank"}
   endpoint to programatically list all images available to your credentials,
   so you don't have supply repositories manually.

1. Set up [authentication](https://cloud.google.com/container-registry/docs/advanced-authentication){:target="\_blank"}.

   A [service account](https://cloud.google.com/compute/docs/access/service-accounts){:target="\_blank"}
   is the preferred way to authenticate to GCR. Use the commands below to create
   and download a service account to be used as your password with the required
   `roles/storage.admin` role, assuming the registry exists in your current
   `gcloud` project.

   (You can use an [access
   token](https://cloud.google.com/container-registry/docs/advanced-authentication#access_token){:target="\_blank"}
   instead, but that's problematic for Spinnaker because the token is short
   lived, and you are responsible for refreshing it.)

   ```bash
   SERVICE_ACCOUNT_NAME=spinnaker-gcr-account
   SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json

   gcloud iam service-accounts create \
       $SERVICE_ACCOUNT_NAME \
       --display-name $SERVICE_ACCOUNT_NAME

   SA_EMAIL=$(gcloud iam service-accounts list \
       --filter="displayName:$SERVICE_ACCOUNT_NAME" \
       --format='value(email)')

   PROJECT=$(gcloud info --format='value(config.project)')

   gcloud projects add-iam-policy-binding $PROJECT \
       --member serviceAccount:$SA_EMAIL \
       --role roles/browser

   gcloud projects add-iam-policy-binding $PROJECT \
       --member serviceAccount:$SA_EMAIL \
       --role roles/storage.admin

   mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

   gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
       --iam-account $SA_EMAIL
   ```

   Your GCR password is now in a file called `$SERVICE_ACCOUNT_DEST`.
   For Spinnaker to authenticate against GCR, keep track of these environment
   vars to be passed to `hal` [later](#add-the-account):

   ```bash
   PASSWORD_FILE=$SERVICE_ACCOUNT_DEST
   ```

1. Enable the provider.

   ```bash
   hal config provider docker-registry enable
   ```

1. Add the account.

   > Note: if you're running Halyard [in a Docker
   > container](/setup/install/halyard/#install-halyard-on-docker), you might
   > have to restart the container, now mounting the `~/.gcp` directory.

   ```bash
   hal config provider docker-registry account add my-docker-registry \
    --address $ADDRESS \
    --username _json_key \
    --password-file $PASSWORD_FILE

   ```

### Amazon Elastic Container Registry (ECR)

1. Set the registry address.

   ECR registry addresses are specific to an AWS account and region.  You can retrieve the address from the ECR console, or with `aws ecr describe-repositories`.

   ```bash
   ADDRESS=012345678910.dkr.ecr.us-east-1.amazonaws.com
   REGION=us-east-1
   ```

1. Enable the provider.

   ```bash
   hal config provider docker-registry enable
   ```

1. Set up authentication.

   Because the Docker Registry API does not support the standard AWS authentication methods, the Halyard `--password-command` option will be configured to use the AWS CLI to retrieve an ECR authentication token on a regular interval with IAM credentials on the Spinnaker instance.  The ECR API returns the authentication token as a base64 encoded string comprised of the username and password, which the password command will decode and retrieve the password from the payload.

   Ensure that the AWS CLI is installed on the Spinnaker instance running the Clouddriver service. For example:

   ```bash
   apt install python3-pip
   pip3 install awscli
   ```

   The Spinnaker instance running the Clouddriver service will also need permissions to interact with the ECR repository.  Attach the `AmazonEC2ContainerRegistryReadOnly` managed policy to the IAM role for your Spinnaker instance profile or (if IAM user credentials are saved in ~/.aws) your Spinnaker IAM user.  For example,

   ```bash
   aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name SpinnakerInstanceRole
   ```

   or:

   ```bash
   aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --user-name spinnaker
   ```

1. Add the account.

   ```bash
   hal config provider docker-registry account add my-ecr-registry \
    --address $ADDRESS \
    --username AWS \
    --password-command aws --region $REGION ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d | sed 's/^AWS://'
   ```

### Other registries

Most registries fit either the Dockerhub or GCR pattern described above,
or some mix of the two. In all cases you need to know the FQDN of the
registry, and your username/password pair if you are accessing private images.
If your registry supports the [`/_catalog`
endpoint](https://docs.docker.com/registry/spec/api/#listing-repositories){:target="\_blank"}
you do not have to list your repositories. If it does not, keep in mind that the
repository names are generally of the form `<username>/<image name>`. Halyard
verifies this for you.

| Registry | FQDN | Catalog |
|----------|------|:-------:|
| GCR | gcr.io, eu.gcr.io, us.gcr.io, asia.gcr.io, b.gcr.io | Yes |
| DockerHub | index.docker.io | No |
| Quay | quay.io | Yes |
| ECR | `account-id`.dkr.ecr.`region`.amazon.aws.com | Yes |
| JFrog Artifactory | `server`-`repo`.jfrog.io | ? |

## Add the account

First, make sure that the provider is enabled:

```bash
hal config provider docker-registry enable
```

Assuming that your registry has address `$ADDRESS`, with repositories
`$REPOSITORIES`, username `$USERNAME`, and password `$PASSWORD`, run the
following `hal` command to add an account named `my-docker-registry` to
your list of Docker Registry accounts:

```bash
hal config provider docker-registry account add my-docker-registry \
    --address $ADDRESS \
    --repositories $REPOSITORIES \
    --username $USERNAME \
    --password # Do not supply your password as a flag, you will be prompted for your
               # password on STDIN
```

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-docker-registry-account-add).

## Next Steps

Optionally, you can [set up another cloud provider](/setup/install/providers/),
but otherwise you're ready to [choose an environment](/setup/install/environment/)
in which to install Spinnaker.
