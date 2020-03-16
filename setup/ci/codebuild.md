---
layout: single
title:  "AWS CodeBuild"
sidebar:
  nav: setup
---

{% include toc %}

Setting up [AWS CodeBuild](https://aws.amazon.com/codebuild/) as a Continuous Integration (CI)
system within Spinnaker allows you to:
 * trigger pipelines when an AWS CodeBuild build changes its phase or state
 * add an AWS CodeBuild stage to your pipeline

The AWS Codebuild stage requires Spinnaker 1.19 or later.

## Prerequisites

### AWS CodeBuild project

You need to have an [AWS CodeBuild](https://aws.amazon.com/codebuild/) project.

### IAM Role

You need to have an [IAM](https://aws.amazon.com/iam/) role that has the following permissions:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:StopBuild",
        "codebuild:ListProjects",
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds"
      ],
      "Resource": "*"
    }
  ]
}
```
This role has to trust the Spinnaker auth role so that the managing account can assume this role to call CodeBuild.
You can edit your trust relationship to add the following policy:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": <Your Spinnaker Auth Role>
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Configure Spinnaker to work with AWS CodeBuild

Use the following Halyard commands to create an AWS CodeBuild account, enable the AWS CodeBuild integration, and re-deploy Spinnaker:
```
hal config ci codebuild account add $ACCOUNT_NAME \
  --accountId $ACCOUNT_ID \
  --assume-role $ASSUME_ROLE \
  --region $REGION

hal config ci codebuild enable

hal deploy apply
```

## Configure an AWS CodeBuild stage

To run an AWS CodeBuild build as part of a Spinnaker pipeline, perform the following steps:

1. Create a stage of type **AWS CodeBuild**.

2. Configure the stage by selecting the following:
   * AWS CodeBuild account to use to run the build
   * The project name from the dropdown list

3. (Optional) In the **Source Configuration** section, you can also do the following:
  - Select the source artifact to use as the build source. If not specified, the source configured in the project is used.
  - Specify the [source version](https://docs.aws.amazon.com/codebuild/latest/APIReference/API_StartBuild.html#CodeBuild-StartBuild-request-sourceVersion).
  of the build source. If not specified, the latest version is used.
  - Specify the buildspec file. If left blank, the buildspec configured in the project is used.
  - Select secondary build sources. If not specified, the secondary sources configured in the project is used.

4. (Optional) In the **Environment Configuration** section, you can specify the image tag or image digest that identifies the Docker image to use. If not specified, the image configured in the project is used. **Note:** As a prerequisite, follow this
[user guide](https://docs.aws.amazon.com/codebuild/latest/userguide/sample-private-registry.html) to set up your registry credentials
in the project configuration.

5. (Optional) In the **Advanced Configuration** section, you can specify environment variables to use in the build.
Only environment variables in plain text are supported. Parameter Store / Secrets Manager environment variables
can be configured in the project.

6. (Optional) In the **Produces Artifacts** section, you can supply any artifacts that you expect the build to create in order to
make these artifacts available to downstream stages. AWS CodeBuild supports creating S3 artifacts in ZIP format, which will be converted
to Spinnaker artifacts and injected into the pipeline on completion of the build.

While your build is running, the stage details provide the following information:
* Current status of the build
* ARN of the build
* The link to view the build in the AWS CodeBuild Console
* The link to view the build logs in AWS CloudWatch Logs
* The link to view the build logs in S3

## Configure your pipeline trigger (Optional)

Configure your pipeline to get triggered when an AWS CodeBuild build completes:

1. Follow these [instructions](https://docs.aws.amazon.com/codestar-notifications/latest/userguide/getting-started-build.html) to
set up a notification rule for your project. To trigger the pipeline on completion of the build,
select **Succeeded** and **Failed** in the **Events that trigger notifications** section under **Build state**.

2. Follow these [instructions](/setup/triggers/amazon/) to create an Amazon Pub/Sub trigger. Keep the following guidelines in mind:
  - Skip the step to create SNS topic, as we will use the SNS topic created in step 1.
  - Create an SQS queue and subscribe the queue to the SNS topic.
  - Skip the step to create an S3 bucket, as the notification will be sent from CodeBuild instead of from S3.
  - Write the Echo configuration and set up the Amazon Pub/Sub trigger in the Spinnaker UI.

3. Start a build in CodeBuild. Your pipeline gets triggered when the build completes.