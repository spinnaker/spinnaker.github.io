---
layout: single
title:  "Next Release Preview"
sidebar:
  nav: community
---

{% include toc %}

Please make a pull request to describe any changes you wish to highlight
in the next release of Spinnaker. These notes will be prepended to the release
changelog.

## Coming Soon in Release 1.24

### Official Docker Registry Has Changed

Official Spinnaker Kubernetes containers have moved from
`gcr.io/spinnaker-marketplace` to
`us-docker.pkg.dev/spinnaker-community/docker`.

If you use Halyard to deploy your containers, this shouldn't affect you. Halyard
will automatically use the new location, since it's written in the BOM files
that Halyard uses to get release information.

All releases are available in the new location. Only releases prior to 1.23 are
available in the old location, and the old location will be disabled in 2021.

### Bake helm charts using git/repo artifacts

The Bake (manifest) stage now accepts git/repo artifacts when baking a helm
chart.  See [this issue](https://github.com/spinnaker/spinnaker/issues/5249) for
background.

### Capacity Provider Strategy support for Amazon ECS

The Amazon ECS provider now supports using a [capacity provider strategy](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html) to deploy your ECS service. 

If the selected ECS cluster has one or more capacity providers configured, users can provide a list of strategies leveraging those capacity providers to use for their ECS service deployment. In order to add the built-in `FARGATE` and `FARGATE_SPOT` capacity providers to an existing cluster, run the following:
```
aws ecs put-cluster-capacity-providers \
     --cluster $MY_CLUSTER \
     --capacity-providers FARGATE FARGATE_SPOT \
     --region $AWS_REGION
```

**NOTE**: If a `capacityProviderStrategy` is specified, the `launchType` parameter must be omitted. 

### Moniker support for Amazon ECS

The Amazon ECS provider now supports a [tag-based](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-using-tags.html) Moniker naming strategy for server groups. Users can opt-in to the use of monikers at the ECS provider level or on a per-account basis by specifying the "tags" naming strategey in their hal config:

```
ecs:
  enabled: true
  defaultNamingStrategy: "default"   <--- 'default' naming used by default (field absent) or if specified
  accounts:
    - name: "ecs-moniker-acct"
      awsAccount: "ec2-aws-acct"
      namingStrategy: "tags"         <--- 'tags' specified for specific account

``` 

**NOTES**: 
  * To use ECS service tags, your Amazon ECS account must be opted into using the _long Amazon Resource Name (ARN)_ format. See [AWS documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-account-settings.html#ecs-resource-ids) for details.
  * This feature adds validation which requires deploy stage `moniker` values for `app`, `stack`, and `detail` to match top-level `application`, `stack`, and `freeFormDetails` values _if both are present_. Existing pipelines which contain both with different values will need to remove one set or update them to match. 

### Amazon ECS Task Definition caching improvements

Starting in 1.24, the Amazon ECS provider will only cache task definitions associated with Amazon ECS services. Previously, every "active" task definition in the account would be cached, regardless of association with a service. This change does not entail any user-facing changes, but operators may notice a smaller cache footprint and fewer API calls to Amazon ECS. 