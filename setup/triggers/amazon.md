---
layout: single
title:  "Amazon AWS Pub/Sub"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker pipelines can be triggered from a queue in [Amazon Simple Queue Service (SQS)](https://aws.amazon.com/sqs/){:target="\_blank"} that receives new notifications from [Amazon Simple Notification Service (SNS)](https://aws.amazon.com/sns/){:target="\_blank"}.

# Prerequisites

You need an AWS Account and the [AWS Command Line Interface (cli)](https://aws.amazon.com/cli/){:target="\_blank"} installed locally and configured with credentials that allow you to manage your AWS cloud resources.

## Creating an Simple Notification Service (SNS) Topic

Use the AWS Command Line tool or the AWS Console website to create a SNS Topic that will receive the messages destined for the queue and Spinnaker. You can do this by running the following commands:

```
 bash4.4$ export AWS_TOPIC_NAME=aws-pubsub-test-topic
 bash4.4$ aws sns create-topic --name ${AWS_TOPIC_NAME}
 {
    "TopicArn": "arn:aws:sns:us-east-1:1234567890:aws-pubsub-test-topic"
 }
```
* Make a note of the TopicArn. You will need this to configure Echo via the echo-local.yml file to tell Spinnaker to subscribe to this topic.

## Creating an Simple Queue Service (SQS) Queue (Optional)

At this point, you can also create an SQS Queue that will receive the notification messages.

Spinnaker will do this part for you, provided that you specify what would be a valid name for the QueueARN in the `echo-local.yml`.

If you'd like to create the queue yourself manually, follow these instructions. Otherwise skip to
the section below about [Configuring your S3 Bucket](#configuring-an-s3-bucket-to-send-notifications).

Use the AWS Command Line tool or the AWS Console website to create an SQS Queue that Spinnaker will listen to. You can do this by running the following commands:

```
 # Create the queue
 bash4.4$ export AWS_QUEUE_NAME=aws-pubsub-test-queue
 bash4.4$ aws sqs create-queue --queue-name ${AWS_QUEUE_NAME}
 {
    "QueueUrl": "https://us-east-1.queue.amazonaws.com/1234567890/aws-pubsub-test-queue"
 }
 # Add the permission for the topic to send messages to the queue
 bash4.4$ aws sqs add-permission --queue-url <QUEUE_URL> --aws-account-ids 1234567890 \
 --label spinnaker-pubsub --actions SendMessage
 # Now get the Queue ARN, you will need this for Spinnaker.
 bash4.4$ aws sqs get-queue-attributes --queue-url <QUEUE_URL> --attribute-names QueueArn
 {
    "Attributes": {
        "QueueArn": "arn:aws:sqs:us-east-1:1234567890:aws-pubsub-test-queue"
    }
 }
 # Now subscribe the queue to the topic you created above.
 bash4.4$ aws sns subscribe --topic-arn arn:aws:sns:us-east-1:12345467890:aws-pubsub-test-topic \
 --protocol sqs --notification-endpoint arn:aws:sqs:us-east-1:1234567890:aws-pubsub-test-queue
 {
    "SubscriptionArn": "arn:aws:sns:us-east-1:1234567890:aws-pubsub-test-topic:e8d02657-e92c-43aa-a785-8d93cb8738fd"
 }
```
* Make a note of this `QueueArn`, as you will need to provide it to Spinnaker in the echo-local.yml file.

You have now set up an SNS topic and created a SQS queue which is subscribed to the topic. When messages are delivered to the topic, they will be delivered to the queue.

## Configuring an S3 bucket to send notifications


The next step is to create an S3 bucket, or use an existing bucket, and automatically deliver notifications when a file is uploaded. The following commands can be used to create a bucket and configure the notifications.

Now you have to tell AWS that your SNS topic can receive messages from your S3 bucket. To do this, you'll need to change the Access Policy for the SNS topic. You can do this by issuing the following command, swapping out the values with the resources created above:

```
# CREATE THE BUCKET
bash4.4$ export AWS_TOPIC_ARN=<INSERT TOPIC ARN HERE>
bash4.4$ export AWS_PUBSUB_BUCKET=spin-pubsub-test-bucket
bash4.4$ aws s3 mb s3://${AWS_PUBSUB_BUCKET}/
make_bucket: spin-pubsub-test-bucket

bash4.4$ aws sns set-topic-attributes --topic-arn ${AWS_TOPIC_ARN} --attribute-name Policy --attribute-value \
"{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"s3Publish\",\
\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":[\"SNS:GetTopicAttributes\",\
\"SNS:Publish\"],\"Resource\":\"${AWS_TOPIC_ARN}\",\"Condition\":{\"ArnLike\":\
{\"aws:SourceArn\":\"arn:aws:s3:::${AWS_PUBSUB_BUCKET}\"}}}]}"
bash4.4$
```
Now that you've given your topic permission to have messages published to it, you can update your bucket's `put-bucket-notification-configuration` with the following `spin-pubsub-notification.json`. You'll need to swap out any values for the values for your configuration.  

```
 # You need to create a file with the notification information in json format
 bash4.4$ cat << EOF > /tmp/spin-pubsub-notification.json
 {
    "TopicConfigurations": [
        {
            "TopicArn": "${AWS_TOPIC_ARN}",
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }
    ]
 }
EOF
 bash4.4$ aws s3api put-bucket-notification-configuration --bucket ${AWS_PUBSUB_BUCKET} \
 --notification-configuration file:///tmp/spin-pubsub-notification.json    
 bash4.4$
```
* Congratulations! You have now done all of the configuration in AWS to send pubsub messages. All we have to do now is configure Spinnaker to subscribe to and retrieve these messages.

## Writing your Echo configuration

Amazon pubsub configuration is not yet supported via Halyard, so you'll need to define the details regarding your subscription in an echo-local.yml file. Put this echo-local.yml file in `~/.hal/<Deployment Profile>/profiles/` directory and Halyard will automatically deploy it alongside echo the next time you run `hal deploy apply`. Halyard's default profile is named `default`, so if you haven't set up a different profile, this `echo-local.yaml` file would go in the `~/.hal/default/profiles/` directory on your halyard instance.

If you are interested in contributing to Spinnaker in code but haven't found something simple to start on, this might be just the thing for you!

```

pubsub:
  enabled: true
  amazon:
    enabled: true
    subscriptions:
    - name: aws-pubsub-test-subscription
      topicARN: arn:aws:sns:us-east-1:1234567890:aws-pubsub-test-topic
      queueARN: arn:aws:sqs:us-east-1:1234567890:aws-pubsub-test-queue
      messageFormat: S3

```

## Turning on Amazon as an option in the UI (Deck)

As of release 1.14.6, Amazon pubsub support is not supported by default in the UI, even if it's configured in echo-local.yaml as laid out above. In order to get `amazon` to show up in the list of pubsub, you must make a slight change to the settings.js file that is deployed with Gate and Deck.

The easiest way to do this is to take it from an existing deployment in Halyard. Each time you run `hal deploy apply`, a copy of the configuration files that are deployed to your Spinnaker instance are copied to your Halyard pod in the ~/.hal/<Deployment Profile>/staging/ directory.

In the staging directory, there is a file called `settings.js`. Copy the `settings.js` file to your `~/.hal/<default profile>/profiles`. Once the file is in your profiles directory, open your favorite editor and find the line that says:
```
  pubsubProviders: ['google'],
```
and change the line to say
```
  pubsubProviders: ['google','amazon'],
```                                                                                                            
Once you have done that, redeploy Spinnaker using the `hal deploy apply` command.   

After the new versions of Echo, Gate and Deck have come up and reported as healthy, you should be able too.

## Troubleshooting

If you don't see your subscriptions after going through these steps, take a look at your Echo logs as the service starts up.

You should see messages from the SQS Provider telling you that the Subscriptions have turned on.
Messaages like this should appear near the top of the logs.

```
INFO 1 --- [           main] c.n.s.e.p.aws.SQSSubscriberProvider      : Bootstrapping SQS for SNS topic: arn:aws:sns:us-east-1:1234567890:aws-pubsub-test
INFO 1 --- [           main] ubsubProperties$AmazonPubsubSubscription : Using message format: S3 to process artifacts for subscription: aws-pubsub-test
INFO 1 --- [pool-2-thread-1] c.n.s.echo.pubsub.aws.SQSSubscriber      : Starting arn:aws:sqs:us-east-1:1234567890:aws-pubsub-queue/SQSSubscriber
```                                                                                                                                                                                                                                                                                                                                                                                                                     
If things aren't working and you want additional info, you can add the following lines to echo-local.yml to get debugging information specific to pubsub.
```
logging:
  level:
    com.netflix.spinnaker.echo.pubsub.aws: DEBUG
```
This will print out a message each time that Spinnaker goes out and attempts to pull messages from the queue.
