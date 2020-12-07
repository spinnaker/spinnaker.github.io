---
layout: single
title:  "Intergate your CI"
sidebar:
  nav: guides
redirect_from: /reference/managed-delivery/intergate-your-CI
---

{% include toc %}

One of Managed Delivery goals is to be able to show a code journey, from committing it until it gets deployed,
in an easy, consistent way.
In order to enable it, we created an integration between MD and the CI provider, which described below.

## Publishing a new artifact

When a new artifact is published, `keel` gets notified by `echo` (for debians) or by `igor` (for dockers). Each artifact has a `metadata` section, which is controlled by the artifact supplier. 
For example, for `docker` artifacts, the `metadata` field is being populated in `clouddriver` based on the docker registry. 

Here is an example of a docker artifact event, that `keel` is tracking:
```
Received artifact published event: ArtifactPublishedEvent(artifacts=[PublishedArtifact(name=mce/agent, type=DOCKER,
	reference=dockerRegistry:v2:testregistry:mce/agent, version=h2012.2626f5f, customKind=false, location=testregistry, artifactAccount=null, provenance=null, uuid=null, metadata={date=1607111907158, registry=testregistry, fullname=mce/agent, tag=tag, commitId=2626f5f, buildNumber=2012, branch=tags/v1.2.0^0}
```

In order to get more metadata per artifact (like build and git details), we created a convension that the `buildNumber` and `commitId` will be part of the artifact metadata object, regardless of the artifact type (it applicable for all types - docker, debians etc.).
In this example, we will query our CI provider to get metadata for build number `2012` and commit id `2626f5f`.

## Artifact Metadata

The metadata per artifact (like commit message, author, timestamp) is visible in the environment view UI, by clicking on an artifact version.

Here's what it looks like in the UI:
{%
  include
  figure
  image_path="./artifact-metadata.png"
%}

In order to get the metadata information, you'll have to plug in your CI provider.
`keel` is calling `igor` to fetch this information. It uses the endpoint `<igorBaseURL>/ci/builds`, which looks like:
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
The response contains a list of builds (we pick the first from the list), which looks like:
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


## Additional features

### See code changes between deployments

Now that we have git metadata for each artifact, we can easily figure out the code differences between each version.
We added the `see changes` button in the UI, for each environment, which looks like:
{%
  include
  figure
  image_path="./see-changes.png"
%}

In slack notifications:
{%
  include
  figure
  image_path="./slack-see-changes.png"
%}


The logic of generating a comparable link is done in `keel`: [ArtifactVersionLinks](https://github.com/spinnaker/keel/blob/master/keel-core/src/main/kotlin/com/netflix/spinnaker/keel/artifacts/ArtifactVersionLinks.kt).
Note: this supports only `stash` at the moment. We'll appreciate contributions for other SCMs!

### Surface build information in the UI
{%
  include
  figure
  image_path="./build-info.png"
%}

A new section called `pre-deployment` is now available in the UI. This section will surface pre deployment steps like baking (for debians only) or building.
By clicking on `see details`, you'll be navigated to the CI view (see below), or a default job log which you can provide as a part of your implementaion (in the `url` field in `Build` object, see above).

### CI view in Spinnaker

We recently added the option to see CI details into Spinnaker, in a new `builds` tab.
It looks like this:
{%
  include
  figure
  image_path="./ci-view.png"
%}

This is a new tab that can be navigated from the main Spinnaker UI.
The UI code (in deck) is calling `gate` service to fetch information, and `gate` is just calling `igor`.

If you wish to use it, this is what you'll need to do:
1. Create a fork to `igor`
2. Implement two endpoints:
- `ci/builds` which returns the `GenericBuild` object.
- `ci/builds/{buildId}/output` which returns the build's log by providing a build number, in a map format:
```
{"log": "...."}
```

- [Controller endpoints](https://github.com/spinnaker/igor/blob/master/igor-web/src/main/java/com/netflix/spinnaker/igor/ci/CiController.java)
- [Generic build service](https://github.com/spinnaker/igor/blob/master/igor-web/src/main/java/com/netflix/spinnaker/igor/ci/CiBuildService.java)
- Example: your service implementation should be something like:
```
 public class YourCompanyNameCIService implements CiBuildService[..]
```
Once both of these endpoints will be implemented, you'll be able to configure your application to show CI information in Spinnaker!

Note: if you already implemented the `/ci/builds` endpoint as descries above, you'll just need to implement the `output` endpoint to get it working!
