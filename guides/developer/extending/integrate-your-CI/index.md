---
layout: single
title:  "Integrate your CI"
sidebar:
  nav: guides
---

{% include toc %}

At Netflix, we built CI integrations to enable features like CI in Spinnaker, fetch artifact metadata and more. You can see the full list of CI features [here](/guides/user/managed-delivery/CI-features).

This guide will explain how to add an integration to your own CI provider, so you'll be able to enjoy the new features we provide.

## CI view in Spinnaker

We recently added the option to see CI details in Spinnaker, in a new `Builds` tab.
It looks like this:
{%
  include
  figure
  image_path="./ci-view.png"
%}

This is a new tab that can be accessed from the main Spinnaker UI.
The UI code (in deck) is calling `gate` service to fetch information, and `gate` is just calling `igor`.

If you wish to use it, this is what you'll need to do:
0. Make sure you are using [gate](https://github.com/spinnaker/gate). Here's the [CiController](https://github.com/spinnaker/gate/blob/master/gate-web/src/main/groovy/com/netflix/spinnaker/gate/controllers/CiController.java) the UI is calling (no need to do any actions here).
1. Create a fork to [igor](https://github.com/spinnaker/igor)
2. Create a new service which implements the [CiBuildService](https://github.com/spinnaker/igor/blob/master/igor-web/src/main/java/com/netflix/spinnaker/igor/ci/CiBuildService.java), and contians two endpoints:
- `ci/builds` which returns the `GenericBuild` object.
- `ci/builds/{buildId}/output` which returns the build's log by providing a build number, in a map format:
```
{"log": "...."}
```

- Example: your service implementation should be something like:
```
 public class YourCompanyNameCIService implements CiBuildService[..]
```
These endpoints are called by the [CiController](https://github.com/spinnaker/igor/blob/master/igor-web/src/main/java/com/netflix/spinnaker/igor/ci/CiController.java).
Once both of these endpoints will be implemented, you'll be able to configure your application to show CI information in Spinnaker!


## Managed Delivery Artifacts

You can read about it more [here](/guides/user/managed-delivery/CI-features).

### Publishing a new artifact

When a new artifact is published, `keel` gets notified by `echo` (for Debian packages) or by `igor` (for Docker images). Each artifact has a `metadata` section, which is populated by the corresponding artifact supplier implementation in `keel`. 
For example, for `docker` artifacts, the `metadata` field is populated by querying `clouddriver`, which stores information from the docker registries configured in the Spinnaker installation. 
Here is an example of a Docker artifact event tracked by `keel`:
```
Received artifact published event: ArtifactPublishedEvent(artifacts=[PublishedArtifact(name=mce/agent, type=DOCKER,
  reference=dockerRegistry:v2:testregistry:mce/agent, version=h2012.2626f5f, customKind=false, location=testregistry, artifactAccount=null, provenance=null, uuid=null, metadata={date=1607111907158, registry=testregistry, fullname=mce/agent, tag=tag, commitId=2626f5f, buildNumber=2012, branch=tags/v1.2.0^0}
```

In order to get additional metadata for each tracked artifact (such as build and git details), we've created a convention that the `buildNumber` and `commitId` will be part of the artifact metadata object, regardless of the artifact type.
In this example, we will query our CI provider to get metadata for build number `2012` and commit id `2626f5f`.

### Getting artifact metadata

Detailed metadata (like commit message, author, timestamp) is visible in the Environments view in the UI, by clicking on an artifact version.

In order to get the metadata information, you'll have to plug in your CI provider.
`keel` [buildService](https://github.com/spinnaker/keel/blob/master/keel-igor/src/main/kotlin/com/netflix/spinnaker/keel/igor/BuildService.kt) is calling `igor` to fetch this information. It uses the endpoint `<igorBaseURL>/ci/builds`, which looks like:
```
  @GET("/ci/builds")
  @Headers("Accept: application/json")
  suspend fun getArtifactMetadata(
    @Query("commitId") commitId: String,
    @Query("buildNumber") buildNumber: String,
    @Query("projectKey") projectKey: String? = null,
    @Query("repoSlug") repoSlug: String? = null,
    @Query("completionStatus") completionStatus: String? = null
  ): List<Build>?
```

At Netflix, we pass as input the `commitId` and `buildNumber`. Those are mandatory.
The response contains a list of [builds](https://github.com/spinnaker/keel/blob/master/keel-igor/src/main/kotlin/com/netflix/spinnaker/keel/igor/model/Build.kt) (we pick the first from the list), which looks like:
```
data class Build(
  val building: Boolean = false,
  val fullDisplayName: String? = null,
  val name: String? = null,
  val number: Int = 0,
  val duration: Long? = null,
  /** String representation of time in nanoseconds since Unix epoch  */
  val timestamp: String? = null,

  val result: Result? = null,
  val url: String? = null, //url to get build details from the CI provider (like jenkins)
  val id: String? = null, //build uid

  val scm: List<GenericGitRevision>? = null,
  val properties: Map<String, Any?>? = null
)
```
The `build` object is a mirror object of [GenericBuild](https://github.com/spinnaker/igor/blob/master/igor-core/src/main/java/com/netflix/spinnaker/igor/build/model/GenericBuild.java) in `igor`.


Note: if you already implemented the `/ci/builds` endpoint as descries above, jump to #3 and you are done!

If you are interested in plugging your CI provider, you'll need to do the following:
1. Create a fork to `igor`
2. Implement the `ci/builds` endpoint, and return a `GenericBuild` response (which is converted to `Build` object above).
- [Controller endpoints](https://github.com/spinnaker/igor/blob/master/igor-web/src/main/java/com/netflix/spinnaker/igor/ci/CiController.java)
- [Generic build service](https://github.com/spinnaker/igor/blob/master/igor-web/src/main/java/com/netflix/spinnaker/igor/ci/CiBuildService.java)
- Example: your service implementation should be somthing like:
```
 public class YourCompanyNameCIService implements CiBuildService[...]
```
3. Make sure the artifacts being sent to `keel` contains the `buildNumber` and `commitId`.


### See code changes between deployments

The logic of generating a comparable link is done in `keel`: [ArtifactVersionLinks](https://github.com/spinnaker/keel/blob/master/keel-core/src/main/kotlin/com/netflix/spinnaker/keel/artifacts/ArtifactVersionLinks.kt).

Note: this supports only `stash` at the moment. We'll appreciate contributions for other SCMs!

### Surface build information in the UI

A new section called "Pre-deployment" is now available in the UI. This section will surface pre-deployment steps like baking (for Debian packages only) or building.
By clicking on "See details", you'll be taken to the CI view (see above), or a default job log which you can provide as a part of your implementation (in the `url` field in `Build` object, see above).