---
layout: single
title:  "Code Conventions for Server-side Components"
sidebar:
  nav: community
---

{% include toc %}

Please consider the following conventions when submitting pull requests to Spinnaker.

## Choice of language

### Java

In any existing module (i.e. a sub-project of an microservice) that already uses Groovy we prefer new code be written in Java.

Spinnaker uses Java 8 and we encourage use of newer features (such as lambdas, the streams API, the `java.time` package, and default interface methods) where appropriate.

### Kotlin

In any module that does _not_ currently use Groovy the language of choice is [Kotlin](https://kotlinlang.org/).
However, it is absolutely fine to write Java code if that's what you're more comfortable with.

There are cross-compilation issues with mixing Groovy and Kotlin in the same source tree.
For that reason, and in the interests of retaining some measure of sanity, we would rather not mix both languages in a single module.

### Groovy

Although much of Spinnaker is written in it, we prefer that new production code should not use Groovy.
It's fine to use Groovy with [Spock](http://spockframework.org/) for writing tests, however.

If your changes touch on Groovy code that would be relatively easy to transform into Java, please feel free to do so.
Interfaces, for example require almost no changes.
Otherwise, changes to existing Groovy code are fine, but any new classes should not be written in Groovy.

Types from the Groovy runtime libraries should not be exposed in the API of any class.
Since Groovy closures can be automatically type-coerced to Java [SAM types](https://dzone.com/articles/java-8-functional-interfaces-sam), please use an appropriate SAM type for parameters or return types that may be implemented with Groovy closures.

## Code formatting

We follow [Google's Java Style Guide](https://google.github.io/styleguide/javaguide.html) for Java.
We follow [ktlint](https://ktlint.github.io/) for Kotlin.

For Groovy and miscellaneous files, please use:

* 2 space indents.
* No more than 1 consecutive line of whitespace.
* Line breaks rather than overly long lines (limit to 120 column width if possible).
* Camel case conventions as per Java.

Code formatting is applied automatically with a git pre-commit hook, but if you need to check or apply code formatting outside of this process:

* Format code: `./gradlew spotlessApply`
* Check code: `./gradlew spotlessCheck`

## Package structure

Spinnaker microservices automatically component-scan for `@Configuration` classes in the `com.netflix.spinnaker.config` package (although we will need to rethink this convention for Java 9 compatibility).
Other classes should be placed in `com.netflix.spinnaker.<service>.<feature>` where `<service>` is the microservice name, for example `orca` or `clouddriver` and `<feature>` is something descriptive of the feature being implemented.

Please do not separate classes into different packages according to _what_ they are.
Packages should represent the group of classes that implement a particular piece of functionality not all components of a particular type.

## Naming things

Please use descriptive but concise names for variables, classes, properties, methods, and so on.
Longer names are good when they add clarity.
Shorter names are good when they reduce redundancy.

### Representing units

It's preferable to use types that properly represent things like durations, or timestamps (`java.time.Duration` and `java.time.Instant` would be ideal in those specific cases).
If that's not practical please include a suffix on the property / variable name that describes the unit.
A property declared as `public long getTimeout()` is ambiguous and can easily lead to errors when developers using your code assume what the units are.

For example, these names are much less likely to result in errors:

```java
public long getTimeoutMillis();
public long getTimeoutSeconds();
```

## Nullability

When writing Java code, please use `@javax.annotation.Nullable` and `@javax.annotation.Nonnull` annotations on return types and parameters of public methods.
This lets the Kotlin compiler make better decisions about the interactions between Kotlin and Java code.

## Date and time values

Please use classes from `java.time` and not `java.util.Date` or `java.util.Calendar`.

## Exceptions

Please select, or create, appropriate exception types rather than throwing overly general things such as `RuntimeException`.

Exception types you create should extend `RuntimeException` (directly or indirectly).
Please try to include descriptive information in exception messages, especially for errors that will be surfaced to the user.

## Testing

We really appreciate contributions that include tests.
Thorough testing at the unit level with maybe an integration test to validate how components tie together is ideal.

### Testing tools

Spinnaker uses [Spock](http://spockframework.org/) for testing Java and Groovy code.

For Kotlin we are still pinning down specific best practices but currently recommend JUnit tests (written in Kotlin) using [AssertJ](https://joel-costigliola.github.io/assertj/) and [Mockito](http://site.mockito.org/) via [mockito-kotlin](https://github.com/nhaarman/mockito-kotlin).
