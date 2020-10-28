---
layout: single
title:  "AWS Launch Templates"
sidebar:
  nav: setup
---

{% include toc %}

> Please note that you should only proceed with this if you have [AWS EC2](/setup/install/providers/aws/aws-ec2) configured as a cloud provider.

AWS uses [launch templates](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchTemplates.html) to specify instance configuration information. Launch templates are the successor of launch configurations. This means that any new instance configuration feature from AWS will only be supported by launch templates. 

Spinnaker still supports launch configurations for backwards compatbility, but recommends enabling launch templates to access any new features that AWS adds. 

## Setup Steps
This section summarizes the steps required to set up launch templates if you are new to using AWS in Spinnaker or if you have already been using AWS as one of your cloud providers. 

### New to AWS
If you are new to Spinnaker or even just new to AWS in Spinnaker, we recommend immediately enabling launch template support for all applications. 

1. Update your clouddriver configuration file, usually `clouddriver.yml`, to enable launch templates for all applications. 
  ```yml
    aws.features.launch-templates.enabled: true
    aws.features.launch-templates.all-applications.enabled: true
  ```
1. Read through the available launch template supported [features](#feature-configuration) to determine which make sense for your users. 
1. Update AWS settings in deck to include the features you identified. Ensure that `enableLaunchTemplates` is `true`. 
  ```js
    providers: {
      aws: {
        serverGroups: {
          enableLaunchTemplates: true,
          enableIPv6: true,
          enableIMDSv2: true,
        }
      }
    }
  ```

### Current AWS User
If you already use AWS as a cloud provider in Spinnaker, we recommend migrating to launch templates. Since there may be pre-existing dependencies on launch configurations, we have created some rollout configurations you can utilize for testing and/or migration.

1. Update your clouddriver configuration file, usually `clouddriver.yml`, to enable launch template support. 
  ```yml
    aws.features.launch-templates.enabled: true
  ```
1. Review the [rollout configurations](#rollout-configuration) and determine which of these you can *temporarily* utilize for your rollout. If you do not need to rollout, stop here and follow the [new AWS users](#new-to-aws) steps instead. 
1. Update `coulddriver.yml`. This step can be repeated as needed throughout your rollout. This is an example config where launch templates is rolled out to two applications in production and all of the test account. It also excludes one application completely:
  ```yml
    aws.features.launch-templates.enabled: true
    aws.features.launch-templates.allowed-applications: "myapp:prod:us-east-1,anotherapp:prod:us-east-1"
    aws.features.launch-templates.allowed-accounts: "test"
    aws.features.launch-templates.excluded-applications: "dangerousapp"
    aws.features.launch-templates.all-applicaitons.enabled: false
  ```
1. Read through the available [features](#feature-configuration) to determine which make sense for your use cases. 
1. Update AWS settings in deck to include the features you identified. Ensure that `enableLaunchTemplates` is `true`. 
  ```js
    providers: {
      aws: {
        serverGroups: {
          enableLaunchTemplates: true,
          enableIPv6: true,
          enableIMDSv2: true,
        }
      }
    }
  ```
1. When you are ready for a complete rollout, enable launch templates for all applications and clean up rollout config in `clouddriver.yml`. 
    ```yml
    aws.features.launch-templates.enabled: true
    aws.features.launch-templates.all-applications.enabled: true
  ```

## Rollout Configuration
If you already use AWS, then your applications may have some dependencies on launch configurations that prevent simple feature enabling. The configuration options beflow were created to aid with testing or a rollout period. Feel free to use whatever combination is best for you. If you would prefer to **skip a rollout**, use the configuration in [New to AWS](#new-to-aws).

<table>
  <thead>
    <tr>
      <th>Config</th>
      <th>Type</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>allowed-applications</td>
      <td>String</td>
      <td>A comma-separated list of one or more allowed applications scoped by account-region pairs ("app:account:region"). This helps with preliminary controlled testing on a handful of applications.</td>
      <td>"testapp:prod:us-east-1"</td>
    </tr>
    <tr>
      <td>allowed-accounts-regions</td>
      <td>String</td>
      <td>A comma-separated list of allowed account-region pairs. This is good for incrementally rolling out to regions within accounts.</td>
      <td>"test:us-east-1"</td>
    </tr>
    <tr>
      <td>allowed-accounts</td>
      <td>String</td>
      <td>A comma-separated list of allowed accounts. This is good for incrementally rolling out launch templates from test to production accounts.</td>
      <td>"test"</td>
    </tr>
    <tr>
      <td>excluded-accounts</td>
      <td>String</td>
      <td>A comma-separated list of accounts to exclude from rollout.</td>
      <td>"prod"</td>
    </tr>
    <tr>
      <td>excluded-applications</td>
      <td>String</td>
      <td>A comma-separated list of applications to exclude from rollout. This helps prevent any edge cases from delaying a wide rollout..</td>
      <td>"myapp1,myapp2"</td>
    </tr>
    <tr>
      <td>all-applications.enabled</td>
      <td>Boolean</td>
      <td>Allows launch tempaltes on any application, except for those that have been excluded. This will override any of the allowed lists, and widely rollout launch templates.</td>
      <td>true</td>
    </tr>
  </tbody>
</table>

## Feature Configuration
Once launch templates are enabled in clouddriver, a new set of features are unlocked. Review the table of features below to determine which features you want to enable in the UI. Users will see enabled features as options when configuring a server group. 
                                                        
<table>
  <thead>
    <tr>
      <th>Feature</th>
      <th>Description</th>
      <th>Deck Config</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>IPv6</td>
      <td>ASGs can associate an IPv6 address to their instances.</td>
      <td><em>enableIPv6</em></td>
    </tr>
    <tr>
      <td>IMDSv2</td>
      <td>Helps mitigate AWS credential theft from the exploitation of SSRF vulnerabilities in web applications. This is only supported by modern SDKs. Learn more from <a target="_blank" href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html">AWS</a>.</td>
      <td><em>enableIMDSv2</em></td>
    </tr>
  </tbody>
</table>

