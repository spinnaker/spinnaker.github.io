---
layout: single
title:  "Amazon Web Services"
sidebar:
  nav: setup
---

{% include toc %}

Create an AWS virtual machine.

1. Goto [AWS Console](https://console.aws.amazon.com) > AWS Identity & Access
  Management > Roles.
  * Click on **Create New Role**.
  * Type "spinnakerRole" in the **Role Name** field. Hit **Next Step**.
  * Click **Select** for the **Amazon EC2** service.
  * Select the checkbox next to **PowerUserAccess**, then click
    **Next Step**, followed by **Create Role**.
  * Click on the role you created.
  * Click on the **Inline Policies** header, then click the link to create an inline policy.
  * Click **Select** for **Policy Generator**.
  * Select **AWS Identity and Access Management** from the **AWS Service** pulldown.
  * Select **PassRole** for **Actions**.
  * Type <code>*</code> (the asterisk character) in the **Amazon Resource Name (ARN)** box.
  * Click **Add Statement**, then **Next Step**.
  * Click **Apply Policy**.
  * Goto [AWS Console](https://console.aws.amazon.com) > EC2.
  * Click **Launch Instance**.
  * Click **Community AMIs** then
  * If the default region where your resources were allocated in [Step 1](#step-1-set-up-your-target-deployment-environment) is <code>us-west-2</code>, click **Select** for the **Spinnaker-Ubuntu-14.04-42 - [ami-cfb87eaf](https://console.aws.amazon.com/ec2/home?region=us-west-2#launchAmi=ami-cfb87eaf)** image. Otherwise, consult [this region-to-AMI mapping table](http://www.spinnaker.io/docs/amazon-ami-ids) to identify an appropriate image to use.
  * Under **Step 2: Choose an Instance Type**, click the radio button
  for **m4.xlarge**, then click **Next: Configure Instance Details**.
  * Set the **Auto-assign Public IP** field to **Enable**, and the **IAM
  role** to "spinnakerRole".
  * Click **Review and Launch**.
  * Click **Launch**.
  * Select the `my-aws-account-keypair` you created earlier.
  * Click **View Instances**. Make note of the **Public IP** field for the newly-created instance. This will be needed in the next step.
  * Note that it will take several minutes for Spinnaker post-configurations to complete.

2. Shell in and open an SSH tunnel from your host to the virtual machine.
  * Add this to ~/.ssh/config

          Host spinnaker-start
            HostName <Public DNS name of instance you just created>
            IdentityFile </path/to/my-aws-account-keypair.pem>
            ControlMaster yes
            ControlPath ~/.ssh/spinnaker-tunnel.ctl
            RequestTTY no
            LocalForward 9000 127.0.0.1:9000
            LocalForward 8084 127.0.0.1:8084
            LocalForward 8087 127.0.0.1:8087
            User ubuntu

          Host spinnaker-stop
            HostName <Public DNS name of instance you just created>
            IdentityFile </path/to/my-aws-account-keypair.pem>
            ControlPath ~/.ssh/spinnaker-tunnel.ctl
            RequestTTY no

  * Create a spinnaker-tunnel.sh file with the following content, and give it execute permissions

          #!/bin/bash

          socket=$HOME/.ssh/spinnaker-tunnel.ctl

          if [ "$1" == "start" ]; then
            if [ ! \( -e ${socket} \) ]; then
              echo "Starting tunnel to Spinnaker..."
              ssh -f -N spinnaker-start && echo "Done."
            else
              echo "Tunnel to Spinnaker running."
            fi
          fi

          if [ "$1" == "stop" ]; then
            if [ \( -e ${socket} \) ]; then
              echo "Stopping tunnel to Spinnaker..."
              ssh -O "exit" spinnaker-stop && echo "Done."
            else
              echo "Tunnel to Spinnaker stopped."
            fi
          fi

  * Execute the script to start your Spinnaker tunnel

          ./spinnaker-tunnel.sh start

  * You can also stop your Spinnaker tunnel

          ./spinnaker-tunnel.sh stop
    
  * Once you have started your Spinnaker tunnel, you can connect to Spinnaker in your browser using the address:

          http://127.0.0.1:9000/
    
# Amazon AMI IDs

Latest AMI build list in JSON available here:
https://kenzan-spinnaker-public-ami-list.s3.amazonaws.com/latest/ami_table.json

Latest AMI build list in MD available here:
https://kenzan-spinnaker-public-ami-list.s3.amazonaws.com/latest/ami_table.md
