---
layout: single
title:  "Pipeline Expression Reference"
sidebar:
  nav: reference
---

{% include toc %}

Pipeline expressions allow you to reference arbitrary values about the
state of your system in the execution of your pipelines. For more information
about how pipeline expressions work, see the
[overview](/guides/user/pipeline/expressions/).

## Syntax elements

Each pipeline expression is made of `$` followed by opening/closing brackets:
`${ }`. Within these brackets, you can add arbitrary expressions to access and
modify the details of your pipeline during pipeline execution.

Note that expressions can't be nested: `${ expression1 ${expression2} }` won't
be evaluated.

### Code

Spinnaker allows you to execute Java code within a pipeline expression. This can
be useful for string manipulation or more advanced custom logic than
would otherwise be possible. For security reasons, you can only call methods of
whitelisted Java classes. You can find the full list of whitelisted classes
[here](#whitelisted-java-classes).

You can use methods directly on existing map values based on their Java class.
For example, you can process a list of values entered as a parameter using
Java's String `split()` function, provided users enter them using a standard
split character. You can process the list `us-east-1,us-west-1,eu-west-1` with
the expression `${parameters.regions.split(",")}`.

You can instantiate new classes inside of an expression using the fully
qualified package name. For example, you might want to use the [SimpleDateFormat](https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html)
class to get the current date in MM-dd-yyyy format. You can do this using the
expression `${new java.text.SimpleDateFormat("MM-dd-yyyy").format(new
java.util.Date())}`.

Similarly, you can call static methods using the syntax
`T(fully.qualified.class.name).methodName()`. For example, to calculate the date
5 days from now, you can call:
`${T(java.time.LocalDate).now().plusDays(5).toString()}`.

### Comparisons

You can use relational operators to compare values in an expression, such as
`${instance["size"] > 400}` or `${parameters["runCanary"] == "true"}`.

Note that you may need to transform some values for the comparisons to work
properly. In the example above, `parameters["runCanary"]` returns a string
rather than a boolean. To use it in a comparision, you need to either compare
it to a string or convert it to a boolean:
`${#toBoolean(parameters["runCanary"]) == true}`.

Another example is that the status attribute of a stage is actually an enum
internally, not a string. To compare the status to a string, you need to call
`.toString()` on the result. For example:
`${#stage("Deploy")["status"].toString() == "SUCCEEDED"}`.

### Functions

The expression language has several built in helper functions that simplify
common use cases. The syntax for calling built-in functions is
`#functionName(params)`. For example, `#fromUrl("http://www.netflix.com")`. See
the full list of functions [here](#helper-functions).

### Lists

You can also use lists in your expressions. Spinnaker always provides a list
called _stages_, which you can use to access each stage by index:
`${execution["stages"][0]}` returns the value of the first stage in your
pipeline.

Note that `stages` is mostly referenced here for illustration purposes. The
value of `stages[i]` depends on the order in which your stages execute, which
makes it fragile. The recommended way to access a specific stage is to use the
[`#stage("Stage Name")` helper function](#stagestring).

### Maps

You can use maps to access data from the JSON representation of your pipeline.
For example, `${trigger["properties"]["example"]}` evaluates to the value of
the `example` trigger property. To see the available values for a given
pipeline, view the execution JSON:
1. Go to an execution of your pipeline.
2. Click on _Details_ to expand the pipeline.
3. Click on the source link under the pipeline execution, which opens a new tab
    containing the JSON details of your pipeline execution.
    _[[screenshot](https://screenshot.googleplex.com/U1rVRjdiqKC.png)]_

Note that while Spinnaker supports both dot (`map.value`) and square bracket
(`map["value"]`) notation, we recommend using square brackets. That is, prefer
`trigger["properties"]["value"]` instead of `trigger.properties.value`. There
are a few places where using dot notation produces unexpected results, such as
after a filter operation or when getting nested JSON values from an URL. Bracket
notation also allows you to access non-alphanumeric properties.

You can filter maps using `.?`. For example, to filter a list of stages by type,
you would use `${execution["stages"].?[type == "bake"]}`. The result is a
list, and can be accessed as such: `${execution["stages"].?[type == "bake"][0]}`
returns the first bake stage in your pipeline.

### Math

You can use arithmetic operations in your expressions, such as
`${trigger["buildInfo"]["number"] * 2}`. You can use helper functions such as
[#toInt](#tointstring) or [#toFloat](#tofloatstring) if type conversion is
necessary.

### Strings

Strings evaluate to themselves: `${"This is a String."}` becomes "This is a
String."

## Helper properties

[Helper properties](/guides/user/pipeline/expressions/#helper-properties) are
attribute shortcuts that you can use in Spinnaker. The specific properties are:

* `execution`: refers to the current pipeline execution.
* `parameters`: refers to pipeline parameters. This is a shortcut for accessing
the value of `trigger["parameters"]`.
* `trigger`: refers to the pipeline trigger.
* `scmInfo`: refers to the git details of either the trigger or the most
recently executed Jenkins stage.
  * `scmInfo.sha1` returns the git commit hash of the last build
  * `scmInfo.branch` returns the git branch name of the last build
* `deployedServerGroups`: refers to the Server Group that was created by the
  last deploy stage. It should look something like:
  `{"account":"my-gce-account",
    "capacity": { "desired":1.0,"max":1.0,"min":1.0},
    "region":"us-central1",
    "serverGroup":"myapp-dev-v005"}`. Note that you can use
    `deployedServerGroups` [as a function](#deployedservergroupsstring) to
    return information about an arbitrary deploy stage.

## Helper functions

### #alphanumerical(String)

Returns the alphanumerical value of the passed-in string. That is, the input
string with all characters aside from A-Z and 0-9 stripped out.

### #deployedServerGroups(String)

Takes the name of a deploy stage as an argument and returns the Server Group
that was created by the specified stage.

### #readJson(String)

Converts a JSON String into a Map that can then be processed further.

### #fromUrl(String)

Returns the contents of the specified URL as a String.

### #jsonFromUrl(String)

Retrieves the contents of the given URL and converts it into either a map or a
list. You can use this to fetch information from unauthenticated URL endpoints.

### #judgment(String)

Returns the selected judgment value from the Manual Judgment stage whose name
matches the input string. Note that `#judgment` is case sensitive:
`${#judgment("my manual judgment stage")}` returns an error if your stage is
named _"My Manual Judgment Stage"_. Note that this function is aliased to the
spelling `#judgement`.

### #manifestLabelValue(String stageName, String manifestKind, String labelKey)

Returns the value of a label with key `labelKey` from a Kubernetes
Deployment or ReplicaSet manifest of kind `manifestKind`, deployed by a 
stage of type `deployManifest` and name `stageName`.

### #propertiesFromUrl(String)

Retrieves the contents of a [Java properties file](https://docs.oracle.com/javase/tutorial/essential/environment/properties.html)
at the given URL and converts it into a map. You can use this to fetch
information from Jenkins properties files or other similar endpoints.

### #stage(String)

A shortcut to get the stage by name. For example, `${#stage("Bake")}` allows
you to access your Bake stage. Note that `#stage` is case sensitive: if your
stage is actually named "bake", `${#stage("Bake")}` will not find it. Remember
that the values for the stage are still under the _context_ map, so you can
access a property via `${#stage("Bake")["context"]["desiredProperty"]}`.

### #stageByRefId(String)

A shortcut to get the stage by its `refId`. For example, `${#stage("3")}` allows
you to access the stage with `refId = 3`.

### #currentStage()

Returns the current stage.

### #stageExists(String)

Checks if a given stage exists. You can search by `name` or `id`.
Returns `true` if at least one stage is found with the `name` or `id` given.  
Since the `id` is generated at runtime, most of the time it will make sense to search by `name` instead.
Note that stage names are set by default so if you create a Webhook stage it will be called Webhook; 
giving the stage a unique name when you create it makes it easier to find when using this helper function.

### #pipelineId(String)

This function looks up the pipeline id given a pipeline name (within the same Spinnaker application). 
This is useful if you generate pipelines programmatically and don't want to modify pipelines to reference a new id
when a dependent pipeline is automatically regenerated.    
For example, `${#pipelineId("Deploy to prod")}` might return `9b2395dc-7a2b-4845-b623-838bd74d059b`.

### #toBoolean(String)

Converts the input string to a boolean.

### #toFloat(String)

Converts a value to a floating point number.

### #toInt(String)

Converts a value to an integer.

### #toJson(Object)

Converts an arbitrary JSON object into a JSON string.

### #cfServiceKey(String stageName)

A shortcut to refer to a service key which has been created in a previous stage.  Remember that the
stage's name is case-sensitive.  Note also that the values for the service key are contained in a
map, so one may access a property via `${#cfServiceKey("stageName")["desiredProperty"]}`.
For example, `${#cfServiceKey("Create MySQL Service Key")["username"]}` will retrieve the `username`
field of a service key which has been created for a MySQL service in a `Create Service Key` stage named
"Create MySQL Service Key".

## Whitelisted Java classes

You can find the code which whitelists Java classes [here](https://github.com/spinnaker/orca/blob/6d0ba0bf8af5e06c5b405b8294f07e7a5a4c335a/orca-core/src/main/java/com/netflix/spinnaker/orca/pipeline/expressions/whitelisting/InstantiationTypeRestrictor.java#L26).
The whitelisted classes are:

* [Boolean](https://docs.oracle.com/javase/8/docs/api/java/lang/Boolean.html)
* [Byte](https://docs.oracle.com/javase/8/docs/api/java/lang/Byte.html)
* [ChronoUnit](https://docs.oracle.com/javase/8/docs/api/java/time/temporal/ChronoUnit.html)
* [Date](https://docs.oracle.com/javase/8/docs/api/java/util/Date.html)
* [Double](https://docs.oracle.com/javase/8/docs/api/java/lang/Double.html)
* [Instant](https://docs.oracle.com/javase/8/docs/api/java/time/Instant.html)
* [Integer](https://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html)
* [LocalDate](https://docs.oracle.com/javase/8/docs/api/java/time/LocalDate.html)
* [Long](https://docs.oracle.com/javase/8/docs/api/java/lang/Long.html)
* [Math](https://docs.oracle.com/javase/8/docs/api/java/lang/Math.html)
* [Random](https://docs.oracle.com/javase/8/docs/api/java/util/Random.html)
* [SimpleDateFormat](https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html)
* [String](https://docs.oracle.com/javase/8/docs/api/java/lang/String.html)
* [UUID](https://docs.oracle.com/javase/8/docs/api/java/util/UUID.html)

## Source code

Source code for the expression language is in the [spinnaker/orca
repository](https://github.com/spinnaker/orca), mostly in the following classes:

* [ContextParameterProcessor class](https://github.com/spinnaker/orca/blob/master/orca-core/src/main/java/com/netflix/spinnaker/orca/pipeline/util/ContextParameterProcessor.java)
* [ExpressionsSupport class](https://github.com/spinnaker/orca/blob/master/orca-core/src/main/java/com/netflix/spinnaker/orca/pipeline/expressions/ExpressionsSupport.java)
* Subclasses of [ExpressionFunctionProvider](https://github.com/spinnaker/orca/blob/master/orca-core/src/main/java/com/netflix/spinnaker/orca/pipeline/expressions/ExpressionFunctionProvider.kt)


## Pipeline expression implementation

The Pipeline Expression syntax is implemented using the [Spring Expression
Language (SpEL)](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/expressions.html).
