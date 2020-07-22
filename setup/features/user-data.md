---
layout: single
title:  "User Data Files and Metadata"
sidebar:
  nav: setup
---

Spinnaker refers to data injected into instances started by Spinnaker as *user data*.
The implementation and naming of this varies from provider to provider, but the resulting functionality is similar.
In AWS, it is known as [User Data](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html){:target="\_blank"}.
In GCP, it is known as [Instance Metadata](https://cloud.google.com/compute/docs/storing-retrieving-metadata){:target="\_blank"}.
The template file used to define the user data is called the *user data file* which is located on the Clouddriver server.
Tokens are replaced in the user data file to provide some specifics about the deployment.
Every instance started has environment variables are set according to the template and the deployment.
This feature is currently supported with the AWS and GCP providers.

## Configuration

The filename and location of the file is configured differently for each provider.
The general format for the template file a simple property file though there are some differences depending on the provider.

Example of setting a Consul server address:

```bash
CONSUL_SERVER_ADDRESS="consul.example.com"
```

The environment variable `CONSUL_SERVER_ADDRESS` will be set on every instance with the value of `consul.example.com`.

Typical usage would be defining environment variables with the values including the environment specific details
to customize the behavior based on account, environment, region, and other things.

Here is the list of replacement tokens:

**Token**          | **Description**
------------------ | ----------------------------------------
`%%account%%`      | Name of the account
`%%accounttype%%`  | Type of the account
`%%env%%`          | Environment of the account
`%%app%%`          | Application being deployed
`%%region%%`       | The deployment region
`%%group%%`        | Name of the server group
`%%cluster%%`      | Name of the cluster
`%%stack%%`        | Stack component of the cluster name
`%%detail%%`       | Detail component of the cluster name
`%%launchconfig%%` | Name of the launch configuration

Example template file using tokens in the values:

```bash
CLOUD_ACCOUNT="%%account%%"
CLOUD_ACCOUNT_TYPE="%%accounttype%%"
CLOUD_ENVIRONMENT="%%env%%"
CLOUD_SERVER_GROUP="%%group%%"
CLOUD_CLUSTER="%%cluster%%"
CLOUD_STACK="%%stack%%"
CLOUD_DETAIL="%%detail%%"
CLOUD_REGION="%%region%%"
```

If the server group udf-example-cluster-v001 was deployed using this template in the account `main`, accountType `streaming`, environment `prod`, in the `east` region, the resulting user data would look like:

```bash
CLOUD_ACCOUNT="main"
CLOUD_ACCOUNT_TYPE="streaming"
CLOUD_ENVIRONMENT="prod"
CLOUD_SERVER_GROUP="udf-example-cluster-v001"
CLOUD_CLUSTER="udf-example-cluster"
CLOUD_STACK="example"
CLOUD_DETAIL="cluster"
CLOUD_REGION="east"
```

### AWS

The location of the template file for AWS is controlled by the `udf.udfRoot` property and the behavior is controlled by the `udf.defaultLegacyUdf` property. The defaults are:

````yaml
udf:
  udfRoot: /apps/nflx-udf
  defaultLegacyUdf: true
````

You probably want to change the location on the filesystem where the template file lives to suit your deployment.
You almost certainly want to change `udf.defaultLegacyUdf=false` as this disables deprecated behavior that is specific to Netflix.
In the `udf.udfRoot` directory, create a file called `udf0`. The contents of this file are base64 encoded and set as the `user-data` for the LaunchConfiguration when a new server group is created.

**Note**: The `udf` property is root level property instead of being nested under the AWS section.

### Google

The path to the template file is controlled by the `--user-data` flag with [Halyard](/reference/halyard/commands/#hal-config-provider-google-account-add).

With Google, the user data file is set per account.
It is best practice to use the same file for different accounts to ensure consistency,
but different user data files can be used for different accounts if needed.
The contents of the this file is parsed and set as the
[Instance Metadata](https://cloud.google.com/compute/docs/storing-retrieving-metadata){:target="\_blank"} on launched instances.
Any metadata defined in the server group configuration within Spinnaker is
appended to the metadata defined by the *user data file*.
The metadata defined in the server group configuration within Spinnaker takes preferences over the metadata defined in the *user data file* if the metadata keys match.
For example, if the environment variable `CLOUD_CLUSTER=%%app%%-%%stack%%` is set in the *user data file*
and in the server group configuration, the metadata section includes `CLOUD_CLUSTER=overridden-stack`
then the final metadata injected into the instance will be `CLOUD_CLUSTER=overridden-stack`.
