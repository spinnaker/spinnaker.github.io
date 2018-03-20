Scripted setup to get your aws account ready for Spinnaker

Replaces setup at https://www.spinnaker.io/setup/install/providers/aws/

## Prep Work
These steps must be completed before you can setup your aws account

### Environment
You can set up AWS from your local machine or from an instance launched in your AWS account.
You need these permissions to set up AWS to run Spinnaker:
```
	ec2:*
	iam:*
	sts:passRole
	sts:AssumeRole
```

If you also want to run `halyard`, you'll need `s3` permissions:
```
	s3:*
```

AWS Inline Policy Example (no restrictions):
```json
{
    "Statement": [
        {
            "Action": [
                "iam:*",
                "ec2:*",
                "s3:*",
                "sts:PassRole",
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
```
A policy giving you access to these resources should be attached to the instance profile you're running this script from. If you've already launched the instance, you can add permissions to the instance profile via the AWS Console.

The permissions listed here are not all of the permissions needed to run Spinnaker. These permissions are just for preparing your aws environment. 

#### Set up local environment

If you're running locally, make sure that you've installed AWS and the credentials user or role that you are using has the required permissions (listed above). Set up the [aws cli](https://docs.aws.amazon.com/rekognition/latest/dg/setup-awscli.html).

#### OR Set up AWS Box

If you're running this from an EC2 instance make sure that the instance profile attached to that instance has the above permissions.

Make sure that the `aws` cli is installed and configured on the machine you're running, and that the env var `AWS_DEFAULT_REGION` is set.

```bash
	sudo apt-get install awscli
	AWS_DEFAULT_REGION=us-west-2 # Or your default region
```

### Provide account details in `fill-me-out.json`
`fill-me-out.json` contains all the details that you provide about your aws setup.

Feel free to change the default names or leave them. They will show up in the UI as identifiers for the account/vpc/subnet.

* `MANAGING_ACCOUNT_ID` is the account ID that Spinnaker is running in.
* `MANAGED_ACCOUNT_IDS` is an array of account IDs of accounts that Spinnaker is managing.
* `AUTH_TYPE` is the [method of authentication](https://www.spinnaker.io/setup/install/providers/aws/#configure-an-authentication-mechanism).
	* If Spinnaker is running inside of EC2, chose "role".
	* If Spinnaker is running outside of EC2, chose "user". This will need to be created through the console following [these steps](https://www.spinnaker.io/setup/install/providers/aws/#option-2-add-a-user-and-access-key--secret-pair).

### Run `setup-aws.sh`
Your specific information will be pulled from `fill-me-out.json`.
The resources that are created will be output in a created file called `aws-arns.json`. Each run of `setup-aws.sh` appends the created resources to this file if it exists.

All created infrastructure resources will be tagged with `spinnaker:setup:TIMESTAMP`, where timestamp is the start time of the script.

### [Optional] Clean up 
All created resource information is stored in `aws-arns.json`. This file is used by `cleanup-aws.sh` to clean up all the resources.
