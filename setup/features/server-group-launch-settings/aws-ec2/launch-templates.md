---
layout: single
title:  "AWS Launch Templates"
sidebar:
nav: setup
---

{% include toc %}

## Enable launch template feature set in Spinnaker
Follow guidelines [here](/features/server-group-launch-settings/aws-ec2/launch-templates-setup.md)

Note: The features supported in Deck come with helpful tool tips that aid in learning about them quickly.
Consider trying them out in Deck before using them in API, especially if you are new to them.

## Launch Template Feature Configuration
Once launch templates are enabled in Clouddriver, a new set of features are unlocked.
Some of them are tied to the Launch Template directly like `IMDSV2` and 
some others require a launch template to be used in order to support features like `SpotAllocationStrategy` ([MixedInstancesPolicy](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_MixedInstancesPolicy.html) features).


Review the sections below for details about the features and sample use cases along with Spinnaker API requests. 

### Launch Template Only Parameters
Review the sections below to determine which features you want to enable in the UI.
Users will see enabled features as options when configuring a Server Group.
<table>
  <thead>
    <tr>
      <th>Feature</th>
      <th style="width=50%;">Description</th>
      <th>Deck Setting</th>
      <th>Clouddriver API Request Parameter</th>
      <th>Release Version</th>
      <th>Default value in Spinnaker</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>IPv6</td>
      <td>ASGs associate an IPv6 address to their instances.</td>
      <td><em>enableIPv6</em></td>
      <td><em>associateIPv6Address</em></td>
      <td><em>v1.21</em></td>
      <td>no default</td>
    </tr>
    <tr>
      <td>IMDSv2</td>
      <td>Helps mitigate AWS credential theft from the exploitation of SSRF vulnerabilities in web applications. This is only supported by modern SDKs. <font size="-1">Learn more from <a target="_blank" href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html">AWS</a>.</font></td>
      <td><em>enableIMDSv2</em></td>
      <td><em>requireIMDSv2</em></td>
      <td><em>v1.21</em></td>
      <td>false</td>
    </tr>
    <tr>
      <td>CreditSpecification</td>
      <td>The credit option for CPU usage of the instance.
      Valid for burstable performance EC2 instances only. <font size="-1">Learn more from <a target="_blank" href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html">AWS</a>.</font></td> 
      <td><em>enableCpuCredits</em></td>
      <td><em>unlimitedCpuCredits</em></td>
      <td><em>v1.24</em></td>
      <td><a target="_blank" href="https://github.com/spinnaker/clouddriver/blob/master/clouddriver-aws/src/main/groovy/com/netflix/spinnaker/clouddriver/aws/deploy/handlers/BasicAmazonDeployHandler.groovy#L488">
          default <em>false</em></a> used only when all instance types in request support bursting.
      </td>
    </tr>
  </tbody>
</table>

### Diversified Server Groups with Launch Templates
Enabling launch templates in Clouddriver also unlocks additional features offered by AWS EC2 AutoScaling that could be helpful for use cases like:
* create Server Groups with flexible instance configuration e.g. multiple instance types, a combination of purchase options (On-Demand / Spot) in order to tap into multiple Spot Instance pools.
* use instance weighting to specify the relative weight of each instance type, to count towards the desired capacity of the group.
* allow AWS to optimize instance allocation by using allocation strategies.
* optimize by capacity but prioritize the list of instance types provided to indicate preference.
* maintain a consistent baseline of On-Demand capacity and use Spot in remaining capacity for cost savings.
* follow [AWS recommended best practices for EC2 Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html) for better user experience.

#### Motivation to diversify instances in your Server Group
* Reduce probability of [InsufficientInstanceCapacity](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/troubleshooting-launch.html#troubleshooting-launch-capacity) exceptions with flexible instance configuration.
* Reduce costs by diversifying instances across purchase options and Spot allocation strategies. See AWS docs to learn more about [how to use Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html).
* Reduce costs and optimize resources with instance weighting.
* Enhance availability by deploying your application across multiple instance types running in multiple Availability Zones.
* Maintain desired Spot capacity by proactively augmenting your fleet with a new Spot instance from an optimal pool before a running instance is interrupted by EC2, by enabling [capacity rebalance](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html).

Using one or more parameters in the table below, in Clouddriver API request will automatically create Server Groups with the instance diversification configuration specified and AWS defaults for those not specified.
Note that a number of these parameters complement each other. So, combining them can greatly enhance your AWS experience.

<table>
  <thead>
    <tr>
      <th>Category</th>
      <th>Feature / Clouddriver API Request Parameter</th>
      <th style="width=50%;">Description</th>
      <th>AWS Default</th>
      <th>Clouddriver Release Version</th>
      <th>Deck Setting</th>
      <th>Deck Release Version</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="3">Multiple instance types with instance weighting and priority, with launch template overrides. 
          <br/><br/>Properties overridden will replace the same properties in launch template.
          <br/><br/>AWS docs: 
          <br/><a target="_blank" href="https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-weighting.html">Instance Weighting</a>
      </td>
      <td><em>launchTemplateOverridesForInstanceType.instanceType</em></td>
      <td>Instance Type to override</td>
      <td>no default</td>
      <td rowspan="2">v1.26</td>
      <td rowspan="2">WIP</td>
      <td rowspan="2">WIP</td>
    </tr>
    <tr>
      <td><em>launchTemplateOverridesForInstanceType.weightedCapacity</em></td>
      <td>The number of capacity units for the specified instance type in terms of virtual CPUs, memory, storage, throughput, or other relative performance characteristic. 
          The capacity units count toward the desired capacity.</td>
      <td>1<br/>i.e. if no weighted capacity is specified, all instance types (large or small) are treated as the same weight.</td>
    </tr>
    <tr>
      <td><em>launchTemplateOverridesForInstanceType.priority</em></td>
      <td>Optional priority for instance type. Lower the number, higher the priority. If unset, the launch template override has the lowest priority.
            <br/>The order of instance types in the list of launch template overrides sent to AWS is set from highest to lowest priority.
        <br/><br/>Valid values: integer > 0.
     </td>
      <td>first to last in list</td>
      <td>v1.27</td>
      <td rowspan="7">WIP</td>
      <td rowspan="7">WIP</td>
    </tr>
    <tr>
      <td rowspan="3">On-Demand
         <br/><br/>AWS docs: 
         <br/><a target="_blank" href="https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html">Instance Diversification</a>
      </td>
      <td><em>onDemandAllocationStrategy</em></td>
      <td>Indicates how to allocate instance types to fulfill On-Demand capacity. The only valid value is <em>prioritized</em>.
          <br/><br/>This strategy uses the order of instance types in the launch template overrides to define the launch priority of each instance type. 
          The first instance type in the list is prioritized higher than the last.</td>
      <td><em>prioritized</em></td>
      <td rowspan="6">v1.26</td>
    </tr>
    <tr>
      <td><em>onDemandBaseCapacity</em></td>
      <td>The minimum amount of the Server Group's capacity that must be fulfilled by On-Demand Instances.
          <br/><br/><b>NOTE</b>: <em>If weights are specified for the instance types in the overrides, set the value of OnDemandBaseCapacity in terms of the number of capacity units, and not number of instances.</em></td>
      <td>0</td>
    </tr>
    <tr>
      <td><em>onDemandPercentageAboveBaseCapacity</em></td>
      <td>The percentages of On-Demand Instances and Spot Instances for additional capacity beyond <em>OnDemandBaseCapacity</em>.</td>
      <td>100<br/>i.e. only On-Demand instances</td>
    </tr>
    <tr>
      <td rowspan="4">Spot
         <br/><br/>AWS docs: 
         <br/>* <a target="_blank" href="https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html">Instance Diversification</a>
         <br/>* <a target="_blank" href="https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html">ASG Capacity Rebalance</a>
         <br/>* <a target="_blank" href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/rebalance-recommendations.html">EC2 Instance Rebalance Recommendations</a>
      </td>
      <td><em>spotAllocationStrategy</em></td>
      <td>Indicates how to allocate instances across Spot Instance pools. 2 strategies:
          <br/>1) capacity-optimized (recommended): instances launched using Spot pools that are optimally chosen based on the available Spot capacity.
          <br/>2) lowest-price: instances launched using Spot pools with the lowest price, and evenly allocated across the number of Spot pools specified in spotInstancePools.
      </td>
      <td><em>lowest-price</em></td>
    </tr>
    <tr>
      <td><em>spotInstancePools</em></td>
      <td>The number of Spot Instance pools across which to allocate Spot Instances. 
          The Spot pools are determined from the different instance types in the overrides.
          Only applicable with 'lowest-price' spotAllocationStrategy.
      </td>
      <td>2</td>
    </tr>
    <tr>
      <td><em>spotPrice</em></td>
      <td>The maximum price per unit hour that the user is willing to pay for a Spot Instance.</td>
      <td>On-Demand price for the configuration</td>
    </tr>
    <tr>
      <td><em>capacityRebalance</em></td>
      <td>Enable to allow Amazon EC2 Auto Scaling to attempt proactive replacement of Spot Instances in the server group that have received a rebalance recommendation (i.e. at elevated risk of interruption), <b>before</b> they are interrupted by AWS EC2.
          Note: Enabling this feature could exceed the server group's max capacity for a brief period of time, leading to higher costs. Learn more in AWS docs.</td>
      <td>false <br/>i.e. disabled</td>
      <td>v1.27</td>
      <td>Advanced Settings > capcity rebalance</td>
      <td>v1.27</td>
    </tr>
  </tbody>
</table>

## Use Cases & Sample Requests

## Sample API request
### Create Server Group with launch template
After enabling the launch template feature set is Clouddriver and/or Deck, set `setLaunchTemplate` to true in order to indicate Spinnaker to create your Server Group with an EC2 Launch Template.
```bash
curl -H 'Content-Type: application/json' -d '{ "job": [ 
  {
    "type": "createServerGroup",
    "cloudProvider": "aws",
    "account": "my_aws_account",
    "application": "myAwsApp",
    "stack": "myStack",
    "credentials": "my_aws_account",
    "availabilityZones": {"us-west-1": ["us-west-1a","us-west-1b","us-west-1c"]},
    "amiName": "ami-12345",
    "capacity": {"desired": 5,"max": 7,"min": 5},
    "iamRole":"BaseInstanceProfile",
    "instanceType":"t3.large",
    "setLaunchTemplate": true,
    "requireIMDSv2": true,
    "unlimitedCpuCredits": true
  }], "application": "myAwsApp", "description": "Create New Server Group in cluster myAwsApp"}' -X POST http://localhost:8084/tasks
```
Let's say, the Server Group created was named `myAwsApp-myStack-v005`. 
It is backed by EC2 Launch Template with IMDSv2 enabled and unlimited CPU credits.

### Convert a Server Group with launch template to use mixed instances policy, with multiple instance types and capacity weighting
The Spinnaker operation, `modifyServerGroupLaunchTemplate`/ `updateLaunchTemplate` also supports 
updating a Server Group backed by launch template to use mixed instances policy when one or more mixed instances policy parameters listed above is specified.

```bash
curl -H 'Content-Type: application/json' -d '{ "job": [ 
  {
    "type": "updateLaunchTemplate",
    "cloudProvider": "aws",
    "account": "my_aws_account",
    "application": "myAwsApp",
    "stack": "myStack",
    "credentials": "my_aws_account",
    "region": "eu-central-1",
    "asgName": "myAwsApp-myStack-v005",
    "launchTemplateOverridesForInstanceType": [
      {"instanceType":"t2.large","weightedCapacity":"1"},
      {"instanceType":"t3.large","weightedCapacity":"1"},
      {"instanceType":"t2.xlarge","weightedCapacity":"2"},
      {"instanceType":"t3.xlarge","weightedCapacity":"2"}] 
  }], "application": "myAwsApp", "description": "Modify Server Group in cluster myAwsApp"}' -X POST http://localhost:8084/tasks
```
Note: instance weighting is requested by vCPUs.

AWS docs:
* [multiple instance types](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html)
* [instance weighting](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-weighting.html)

### Diversify instances in a Server Group across purchase options (On-Demand and Spot), multiple instance types with priority assignment:
```bash
curl -H 'Content-Type: application/json' -d '{ "job": [ 
  {
    "type": "createServerGroup",
    "cloudProvider": "aws",
    "account": "my_aws_account",
    "application": "myAwsApp",
    "stack": "myStack",
    "credentials": "my_aws_account",
    "availabilityZones": {"us-west-1": ["us-west-1a","us-west-1b","us-west-1c"]},
    "amiName": "ami-12345",
    "capacity": {"desired": 5,"max": 7,"min": 5},
    "iamRole":"BaseInstanceProfile",
    "instanceType":"m4.large",
    "setLaunchTemplate": true,
    "onDemandBaseCapacity":1,
    "onDemandPercentageAboveBaseCapacity":50,
    "spotAllocationStrategy":"lowest-price",
    "spotInstancePools": 2,
    "launchTemplateOverridesForInstanceType": [
      {"instanceType":"m5.large","weightedCapacity":"1","priority": 2},
      {"instanceType":"m5.xlarge","weightedCapacity":"2","priority": 1}] 
  }], "application": "myAwsApp", "description": "Create New Server Group in cluster myAwsApp"}' -X POST http://localhost:8084/tasks
```

See capacity type for instances in Deck:
<div style="display: flex;">
    <img src="../capacity_type_ondemand.png" width="200" height="200" alt="Capacity Type On-Demand">
    <img src="../capacity_type_spot.png" width="200" height="200" alt="Capacity Type Spot">
</div>

AWS docs:
* [instance diversification in ASG](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html)
* [allocation strategies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies)

### Create a Server Group with AWS recommended best practices for EC2 Spot
The best practices followed in the example:
* use multiple instance types
* use `capacity-optimized` Spot allocation strategy to indicate AWS to provision instances from the most-available Spot capacity pools
* use default maximum price for Spot i.e. On-Demand price
* mix in previous generation instance types
* use proactive capacity rebalancing (works best with `capacity-optimized` spotAllocationStrategy)

```bash
curl -H 'Content-Type: application/json' -d '{ "job": [ 
  {
    "type": "createServerGroup",
    "cloudProvider": "aws",
    "account": "my_aws_account",
    "application": "myAwsApp",
    "stack": "myStack",
    "credentials": "my_aws_account",
    "availabilityZones": {"us-west-1": ["us-west-1a","us-west-1b","us-west-1c"]},
    "amiName": "ami-12345",
    "capacity": {"desired": 5,"max": 7,"min": 5},
    "iamRole":"BaseInstanceProfile",
    "instanceType":"m4.large",
    "setLaunchTemplate": true,
    "onDemandPercentageAboveBaseCapacity":50,
    "onDemandBaseCapacity":1,
    "spotAllocationStrategy":"capacity-optimized",
    "capacityRebalance": true,
    "launchTemplateOverridesForInstanceType": [
      {"instanceType":"m4.large","weightedCapacity":"1"},
      {"instanceType":"m5.large","weightedCapacity":"1"},
      {"instanceType":"m4.xlarge","weightedCapacity":"2"},
      {"instanceType":"m5.xlarge","weightedCapacity":"2"}] 
  }], "application": "myAwsApp", "description": "Create New Server Group in cluster myAwsApp"}' -X POST http://localhost:8084/tasks
```
Note: instance weighting requested by vCPUs

AWS docs:
* [Best practices for ASG with Spot instances](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html#asg-spot-best-practices)
* [Best practices for EC2 Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html)
