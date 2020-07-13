---
layout: single
title: "Getting Set Up for Spinnaker Development on AWS"
sidebar:
  nav: guides
---

{% include toc %}

This guide describes how a developer can set up a [Local Git deployment](/setup/install/environment/#local-git) of Spinnaker on Amazon EC2.

In this setup, Spinnaker runs on an EC2 instance. Code is edited on the machine and then synced to the EC2 instance for testing.


# Configure local machine

1. Create forks of all the [Spinnaker microservices](/reference/architecture/#spinnaker-microservices) on GitHub.
2. Clone them onto your local machine in a dedicated `/spinnaker` directory. This will simplify syncing them in a batch during development.
3. Set up [Intellij](/guides/developer/getting-set-up/#intellij) for Spinnaker as specified.


# Configure development region

1. Provision some roles for Spinnaker. The specific permissions necessary for each role may vary depending on what AWS providers you wish to use, but in general you will need:

    * `SpinnakerDevInstanceRole`: The instance role to be used by your Spinnaker developer instance.
        * Trust policy should include `ec2.amazonaws.com`
        * Attached policy permissions should include:
            * Amazon S3 full access (for persistent storage)
            * `ec2:DescribeRegions` + `ec2:DescribeAvailabilityZones`
            * The ability to assume the `SpinnakerManagedRole` (described below)
            * Read-only access to Amazon Elastic Container Registry, if using private docker images.

    * `SpinnakerManagedRole` : The role Spinnaker will assume to interact with your AWS resources. See the [AWS Setup Guide](/setup/install/providers/aws/) for more details.

2. In the AWS console, in the region where you want your development instance to reside, [create a key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair). 

3. In the default VPC of the same region, [create a security group](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html#CreatingSecurityGroups) named "SpinnakerDev" and [add a rule](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html#AddRemoveRules) allowing port 22 inbound for a restricted set of IPs (for example, corporate firewall ranges). 

4. Provision a development instance that uses these resources with the following steps:
    * From the AWS Console, navigate to the EC2 [launch instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/launching-instance.html) wizard
    * Select an _Ubuntu Server 16.04_ Amazon machine image
    * Select an instance type with sufficient resources to run all the Spinnaker microservices, such as _m5.4xlarge_
    * On the "instance details" step:
        * select the default VPC for "Network" 
        * select the previously created `SpinnakerDevInstanceRole` for "IAM role"
        * under "Advanced Details", add the following user data which will install some dependencies for your [Local Git deployment](/setup/install/environment/#local-git):
        
        ```
        #!/bin/bash
        set -ex

        # Install dependencies for localgit installation
        add-apt-repository ppa:openjdk-r/ppa
        apt-get update
        apt-get -y install git curl netcat redis-server openjdk-8-jdk emacs awscli python2.7 python-pip
        ```

    * Increase the storage snapshot size to ~100GB
    * For tags, add key: "Name" with value: "SpinnakerDev", to help identify it after creation
    * Select the previously created `SpinnakerDev` security group you just created
    * Click "Launch", select the key pair you just created (or another you can use for SSH), and hit "Launch Instances"

# Configure Development EC2 Instance

Get your instance's DNS name and [login via SSH](https://docs.aws.amazon.com/quickstarts/latest/vmlaunch/step-2-connect-to-instance.html). 

```
ssh -A -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ubuntu@$SPINNAKER_INSTANCE_DNS -i /path/to/my-key-pair.pem
```

Install dependencies:

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source ~/.bashrc
nvm install stable
npm install -g yarn

curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh
source ~/.bashrc
hal -v
```

Configure and deploy the Spinnaker installation:

```
# Store state in S3 and deploy a recent stable version
hal config storage s3 edit --region $AWS_REGION   # use region where your dev instance resides
hal config storage edit --type s3
hal config version edit --version 1.21.0  # or whichever is latest
hal deploy apply

sudo service apache2 stop
sudo systemctl disable apache2

# Workaround: https://github.com/spinnaker/spinnaker/issues/4041
echo > ~/.hal/default/profiles/settings-local.js

# Clone repos from your GitHub account
hal config deploy edit --type localgit --git-origin-user={your github username}
hal config version edit --version branch:master

# Connect your AWS account
## Replace the account id specified below (123456789012) with your own account id.
hal config provider aws account add my-aws-devel-acct \
    --account-id 123456789012 \
    --assume-role role/SpinnakerManaged
hal config provider aws account edit my-aws-devel-acct --regions $AWS_REGIONS  # regions you want Spinnaker to deploy to
hal config provider aws enable

# Connect your Docker registries
hal config provider docker-registry enable

hal config provider docker-registry account add my-dockerhub-devel-acct \
    --address index.docker.io \
    --repositories {your dockerhub username}/{your dockerhub repository} \
    --username {your dockerhub username} \
    --password \
    --track-digests true

# Replace the address specified below (123456789012.dkr.ecr.us-west-2.amazonaws.com) with the address to your own ecr registry.
hal config provider docker-registry account add my-us-west-2-devel-registry \
 --address 123456789012.dkr.ecr.us-west-2.amazonaws.com \
 --username AWS \
 --password-command "aws --region us-west-2 ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d | sed 's/^AWS://'" \
 --track-digests true
```

Optionally connect Amazon ECS to your AWS account:

```
hal config provider ecs account add ecs-my-aws-devel-acct --aws-account my-aws-devel-acct
hal config provider ecs enable
```

Deploy everything:

```
hal deploy apply
```

Wait for Clouddriver to start up by checking the logs in ~/dev/spinnaker/logs/clouddriver.log.

```
# Clouddriver start up msg displays after all gradle tasks are run
...
> Task :clouddriver-web:run
      ___                       __
     /\_ \                     /\ \
  ___\//\ \     ___   __  __   \_\ \
 /'___\\ \ \   / __`\/\ \/\ \  /'_` \
/\ \__/ \_\ \_/\ \L\ \ \ \_\ \/\ \L\ \
\ \____\/\____\ \____/\ \____/\ \___,_\
 \/____/\/____/\/___/  \/___/  \/__,_ /

  __
 /\ \         __
 \_\ \  _ __ /\_\  __  __     __   _ __
 /'_` \/\`'__\/\ \/\ \/\ \  /'__`\/\`'__\
/\ \L\ \ \ \/ \ \ \ \ \_/ |/\  __/\ \ \/
\ \___,_\ \_\  \ \_\ \___/ \ \____\\ \_\
 \/__,_ /\/_/   \/_/\/__/   \/____/ \/_/


2020-06-04 21:09:28.940  INFO 29524 --- [           main] b.c.PropertySourceBootstrapConfiguration : Located property source: CompositePropertySo
urce {name='configService', propertySources=[]}
2020-06-04 21:09:28.946  INFO 29524 --- [           main] com.netflix.spinnaker.clouddriver.Main   : The following profiles are active: composite
,test,local
...
```


# Daily development
## Test Spinnaker Code Changes

Sync your changes to the development instance with `rsync`:
```
rsync --progress -a -e "ssh -i /path/to/my-key-pair.pem" --exclude='*/build/' --exclude='*/.idea/' --exclude='*/out/' --exclude='*/.gradle/' ~/code/spinnaker/ ubuntu@$SPINNAKER_INSTANCE_DNS:/home/ubuntu/dev/spinnaker

# Optional:
ssh ubuntu@$SPINNAKER_INSTANCE_DNS 'for i in ~/dev/spinnaker/*; do (cd $i && echo $i && git checkout master && git clean -fdx); done'
```

* If `rsync` isn't an option, you can also push your changes to a remote branch of your fork(s) and manually pull them down to your dev instance before deploying.

[Login to the instance](https://docs.aws.amazon.com/quickstarts/latest/vmlaunch/step-2-connect-to-instance.html), deploy the changes, and check for build or service failures:
```
ssh -A -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ubuntu@$SPINNAKER_INSTANCE_DNS -i /path/to/my-key-pair.pem

hal deploy apply
# or for individual service changes: hal deploy apply --service-names=clouddriver,deck,{other_service_with_changes}

cd ~/dev/spinnaker/logs
```

Test your changes manually at http://localhost:9000.

## Regularly sync from upstream

Add the following to your local machine's .bashrc file
```
sync-from-upstream() {
    for i in ./*; do
        (cd $i && echo $i && git checkout master && git pull --rebase upstream master && git push origin upstream/master:master)
    done
}
```

Regularly run `sync-from-upstream` in your `/spinnaker` directory to keep your local repos and GitHub forks in sync with upstream Spinnaker. Syncing daily or every couple of days will ensure you're working off the latest code for each service.  

## Local development with `spinnaker/deck`

To expedite development of [Deck](https://github.com/spinnaker/deck) or to add ad-hoc `console.log` statements for debugging, you can run the web app on your local machine and connect to the services on your development instance over SSH.

1. After forking and pulling down Deck locally, install dependencies with `yarn` (see [README](https://github.com/spinnaker/deck/blob/master/README.md#prerequisites))

2. Run Deck with `yarn run start`
    * Windows users can circumvent the bash start up script by running it directly with **npm**: `npm run start-dev-server`

3. Open a separate terminal and [SSH into your development instance](https://docs.aws.amazon.com/quickstarts/latest/vmlaunch/step-2-connect-to-instance.html):
```
ssh -A -L 8084:localhost:8084 -L 8087:localhost:8087 ubuntu@$SPINNAKER_INSTANCE_DNS -i /path/to/my-key-pair.pem
```

4. Access local Deck on `localhost:9000`. Changes made & saved to your local app will prompt the app to refresh.

NOTE: feature flags that would be set as environment variables on your development instance can be manually turned on/off in local deck by setting them in [`settings.js`](https://github.com/spinnaker/deck/blob/master/settings.js).


# Troubleshooting

Below are some issues you may encounter when running or setting up your dev instance, and how you might remedy them.

## "Pool Not Open"

Example exception found in Clouddriver log:
```
Example Exception (Found in the Clouddriver log file)
2019-08-14 19:30:34.381 ERROR 24799 --- [gentScheduler-1] c.n.s.c.r.c.ClusteredAgentScheduler      : Unable to run agents
redis.clients.jedis.exceptions.JedisConnectionException: Could not get a resource from the pool
	at redis.clients.util.Pool.getResource(Pool.java:53) ~[jedis-2.9.3.jar:na]
	at redis.clients.jedis.JedisPool.getResource(JedisPool.java:226) ~[jedis-2.9.3.jar:na]
	at com.netflix.spinnaker.kork.jedis.telemetry.InstrumentedJedisPool.getResource(InstrumentedJedisPool.java:60) ~[kork-jedis-5.11.1.jar:5.11.1]
	at com.netflix.spinnaker.kork.jedis.telemetry.InstrumentedJedisPool.getResource(InstrumentedJedisPool.java:26) ~[kork-jedis-5.11.1.jar:5.11.1]
	at com.netflix.spinnaker.kork.jedis.JedisClientDelegate.withCommandsClient(JedisClientDelegate.java:45) ~[kork-jedis-5.11.1.jar:5.11.1]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.acquireRunKey(ClusteredAgentScheduler.java:178) ~[cats-redis.jar:na]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.acquire(ClusteredAgentScheduler.java:131) ~[cats-redis.jar:na]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.runAgents(ClusteredAgentScheduler.java:158) ~[cats-redis.jar:na]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.run(ClusteredAgentScheduler.java:151) ~[cats-redis.jar:na]
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511) [na:1.8.0_222]
	at java.util.concurrent.FutureTask.runAndReset(FutureTask.java:308) [na:1.8.0_222]
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.access$301(ScheduledThreadPoolExecutor.java:180) [na:1.8.0_222]
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:294) [na:1.8.0_222]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_222]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_222]
	at java.lang.Thread.run(Thread.java:748) [na:1.8.0_222]
Caused by: java.lang.IllegalStateException: Pool not open
...
```

It's likely that there is another exception that has occurred when Clouddriver started up (that can be found near the top of the log file). This means that Clouddriver failed to start up successfully, and you will see this stacktrace in the logs for every second (or the defined the polling frequency) that Clouddriver is running with the initial exception.

* Check the top of the log file (if the file is too large, you can use the `head` command to check the top of the file):
```
head -{number of lines} {log file}
# For instance, if you're looking up the first 1000 lines of the Clouddriver log file.
head -1000 dev/spinnaker/logs/clouddriver.log
```
* The first exception that you see (e.g., failed API call or authentication issue) is likely the root cause.


## "Address already in use"

Example exception found in Clouddriver log:
```
org.apache.catalina.LifecycleException: Protocol handler start failed
	at org.apache.catalina.connector.Connector.startInternal(Connector.java:1008) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:183) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.catalina.core.StandardService.addConnector(StandardService.java:227) [tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.springframework.boot.web.embedded.tomcat.TomcatWebServer.addPreviouslyRemovedConnectors(TomcatWebServer.java:263) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.web.embedded.tomcat.TomcatWebServer.start(TomcatWebServer.java:195) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.startWebServer(ServletWebServerApplicationContext.java:296) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.finishRefresh(ServletWebServerApplicationContext.java:162) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:552) [spring-context-5.1.8.RELEASE.jar:5.1.8.RELEASE]
    ...
Caused by: java.net.BindException: Address already in use
	at sun.nio.ch.Net.bind0(Native Method) ~[na:1.8.0_222]
	at sun.nio.ch.Net.bind(Net.java:433) ~[na:1.8.0_222]
	at sun.nio.ch.Net.bind(Net.java:425) ~[na:1.8.0_222]
	at sun.nio.ch.ServerSocketChannelImpl.bind(ServerSocketChannelImpl.java:223) ~[na:1.8.0_222]
	at sun.nio.ch.ServerSocketAdaptor.bind(ServerSocketAdaptor.java:74) ~[na:1.8.0_222]
	at org.apache.tomcat.util.net.NioEndpoint.initServerSocket(NioEndpoint.java:230) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.tomcat.util.net.NioEndpoint.bind(NioEndpoint.java:213) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.tomcat.util.net.AbstractEndpoint.bindWithCleanup(AbstractEndpoint.java:1124) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.tomcat.util.net.AbstractEndpoint.start(AbstractEndpoint.java:1210) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.coyote.AbstractProtocol.start(AbstractProtocol.java:585) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.catalina.connector.Connector.startInternal(Connector.java:1005) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	... 17 common frames omitted
```

If you get this exception when running `hal deploy apply`, check that you don't already have an instance of that microservice currently running (perhaps as root or another user). Check that the [spinnaker microservice ports](https://www.spinnaker.io/reference/architecture/#port-mappings) are not already in use.

The following would be an example of how to debug this exception for Clouddriver (port 7002):
* Check if the port for the given microservice is in use, and make a note of the process id (pid) that is using it. For instance for Clouddriver, you would do the following:
```
sudo netstat -plnt | grep {port}
# For CloudDriver
sudo netstat -plnt | grep 7002 
```
* Using the process id (pid) determined above, check what process is using the open port:
```
ps -ef | grep {pid}
# For instance, if the process id was 12345
ps -ef | grep 12345
```
* If the process is another instance of the Spinnaker microservice that you're trying to start, you can kill the process
```
kill -9 {pid}
# For instance, if the process id was 12345
kill -9 12345
```
* Try re-running `hal deploy apply`
