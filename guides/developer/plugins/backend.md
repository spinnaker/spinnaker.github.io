---
layout: single
title:  "Backend Service Extension Points"
sidebar:
  nav: guides
redirect-from:
  - /guides/developer/plugin-core-developers/backend/
---

{% include toc %}

## Project Setup

To enable plugins for a service, you only need to do two things:

1. Add `implementation("com.netflix.spinnaker.kork:kork-plugins")` to your `{service}-core` module.
2. Add `@Import(PluginsAutoConfiguration::class)` on your `Main` class or somewhere that will always be loaded.

Once the plugin framework is installed, you must create an API module to home your service extension points.

### API Module

Plugins are all about the API. Ensure your project has a `{service}-api` module (called "*the API module*" from now on). The API module **MUST NOT** have other project module dependencies: Your `{service}-core` module (called the "*core service module*") will actually *depend on* the API module, as it is the core's and other modules' responsibility to marshal between internal data structures and objects and the external API contracts.

#### Minimal transitive API module dependencies

The core service and plugins will evolve separately, so the API surface must be kept to a bare minimum, which includes interfaces and POJOs, but also `api`, `implementation` and `runtime` library dependencies.

> **Why avoid library dependencies?**
>
> Plugins are loaded into their own ClassLoader, but if the byte code of the API changes between what a Plugin is compiled against and what the service is compiled against, runtime exceptions will be thrown, causing the service to fail to start. Minimizing transitive dependencies reduces the risk of plugins breaking service deployments.

There are some "blessed" library dependencies. These libraries are considered fair-game to include as they are fairly stable modules or designed for extension point and plugin use:

- `com.netflix.spinnaker.kork:kork-annotations`
- `com.netflix.spinnaker.kork:kork-exceptions`
- `com.netflix.spinnaker.kork:kork-plugins-api`
- `javax.inject:javax.inject`
- `org.slf4j:slf4j-api`

You are *typically* welcome to add other dependencies as you see fit, but understand the more dependencies added, the higher risk you're exposing the service and plugins to breakages. 

#### Language Choices

While the large parts of Spinnaker are written using Kotlin, including the entirety of the plugin framework, use of anything but Java in service API modules is strongly discouraged. Any JVM-based language requires additional dependencies, and those dependencies will need to be carefully managed. Furthermore, the service API module, as opposed to any of the other service modules, is a *library module meant for external consumption*: we cannot assume that people will want to use Kotlin or other languages built atop the JVM, so we should not burden them with the additional dependency.

Plugin developers are free to use whatever JVM language they like.

#### Illegal Module Dependencies

Some dependencies are simply a no-go. Here's a non-exhaustive list of dependencies that must not be included in your API module dependencies:

- Any Spring library
- Any Jackson library

Don't worry, there are established, safe patterns for exposing POJOs for Jackson serialization covered later.

> **Lombok is allowed, but discouraged.** The Spinnaker project is looking to deprecate Lombok usage due to tooling difficulties, such as static code analysis. Please do not introduce it if the API module does not already have it.

The surface area of these libraries (and others like them) are so large and include so many transitive dependencies, it's likely plugin developers will be unable to keep up with changes, and will have frequent ClassLoader issues when their plugin is used, meaning your service — despite having extension points — will be difficult to extend.

> **But what about `kork-plugins-spring-api`? That exposes Spring dependencies!**
>
> True, it does, but *plugin developers* are acknowledging and assuming the risk of using this up front — it's the plugin developer's choice in this case. We do not recommend using this module as a go-to.

## Remote vs. In-Process Extension Points

Extension Points can be targeted for different drivers: *in-process* (JVM) or *remote invocation* (RPC, typically). While some extension points can implement both without issue, most extension points will need upfront design consideration on how you want extension points to be interacting with the service and vice-versa.

For in-process extension points, entire rich object trees can be passed between a plugin and service code quite easily, whereas in a remote world, only data (serialized POJOs) can be transmitted through the extension point contracts.

- Remote
    - **Pro**: Updates to plugins do not require service restarts.
    - **Pro:** Does not affect core service startup times.
    - **Pro:** In-process plugins can implement remote extension points as well.
    - **Pro:** Plugins can be written in any technology stack the developer is familiar with.
    - **Con:** Cannot integrate as deeply with core service.
    - **Con:** Invocations will be more latent.
    - **Con:** Network-related points of failure are more likely.
- In-process
    - **Pro:** Can more deeply integrate with core services than remote plugins.
    - **Pro:** Simpler integration testing story.
    - **Con:** Updates require service restarts / re-deployments.
    - **Con:** Increases service resource utilization, slows down startup times.
    - **Con:** Requires plugin developers to use JVM toolchains.

Remote extensions should be the preference whenever possible; they allow us (or whomever) to deliver changes to features separately from core service functionality and vice-versa. There are, however, times where choosing JVM is better or the only option:

1. If migrating existing functionality, it's almost assured that it must be a JVM extension point. Examples of this would be Orca's `StageDefinitionBuilder` extension point, or Keel's `ConstraintEvaluator` extension point. Existing functionality can be bridged to remote extension points, however, see *Retrofitting Existing Extension Points for Remote.*
2. Library-level extensions. An easy example of this would be changing the Micrometer backend of services. Rather than compiling all Micrometer backends into the application, a plugin can be introduced to bring the dependencies along and then hook into each service's `Registry`.

Consider how often an extension will be invoked. For example, if an extension point is called within a tight loop or is latency-sensitive, a remote driver may be a poor choice.

Reason about remote extension points as you would any other remote service call, because at the end of the day, that's exactly what it is. Design APIs for idempotence: while you will be responsible for how extension points are called, Spinnaker's remote delivery preference is for *at-least-once* delivery, so idempotent APIs are critical.

## Getting Started in Extension Point Development

### Common Guidance

Before getting into developing in-process or remote extension points, there are some common guidances that should be observed.

#### Limiting Exposure

Limiting the exposure of service internals must be a consideration while developing your extension point. While exposing the raw internals of a service is powerful, it makes the extension point more brittle and the core service more resistant to change. A more tightly-coupled extension point is powerful, but refactors may make it less likely for investment in the particular extension point.

#### Documentation

Extension Points are the entry point to services, as far as integrations are concerned, so they should be well documented. Normally, a service API module will already have static code analysis setup to require documentation, but these tools do not measure quality. Assume that consumers of this documentation are largely unfamiliar with the service codebase and link to relevant sources, and explain contextual behavior where it makes sense.

#### Null Safety

Being explicit about null safety is a critical aspect of extension point development. Use `package-info.java` to declare `@NonnullByDefault` (offered via `kork-annotations`) and explicitly set `@Nullable` where properties, methods or return types are nullable.

Note that these annotations are build-time only: You may still yet have to assert nullability within service integration points.

#### Stability Annotations

A service's API module is going to be in varying states of stability between any given release. Stability annotations are provided, and should be used, whenever an extension point is created, both annotations are offered by `kork-annotations`:

- `@Alpha`: Declares that a public API is subject to incompatible changes or even removal in a future release. Features that are in an Alpha state are disabled by default and enabling may introduce bugs. They further do not carry long-term support and may be dropped at any time and without notice. There are no requirements for backwards compatibility.
- `@Beta`: Declares that a public API is subject to incompatible changes, but includes a commitment to support the feature long-term with the caveat that the implementation can still change (even dramatically). Beta features may be potentially enabled by default, and carry an implication that they are reasonably well-tested.

These annotations can be defined broadly on class, as well as specific methods and properties. The absence of any stability annotation indicates that the API is stable and supported.

Deprecations are also supported. Use of Java's `@Deprecated` annotation should be used *and additionally* use `@DeprecationInfo`, which provides API module consumers more structured information on deprecations, including reasoning, EOL version, Github issue link, and so-on. 

### In-Process Extension Points

Developing an in-process extension point is easy! All you need to do is create an interface in the API module which implements `SpinnakerExtensionPoint`. For example:

```kotlin
import com.netflix.spinnaker.kork.plugins.api.internal.SpinnakerExtensionPoint

interface CoolExtensionPoint : SpinnakerExtensionPoint
```

The `SpinnakerExtensionPoint` interface is a subtype of PF4J's `ExtensionPoint` interface, which has internal uses within the plugin framework, as well as creating a clear definition of what specific types in the service API module are extension points versus supporting types and code.

Extensions (plugin classes that implement `SpinnakerExtensionPoint`) may be wrapped in a proxy class for various purposes. In these cases, `instanceof` operations will need to use the `getExtensionClass()` method.

Aside from this one method, an `ExtensionPoint` interface can take any form needed, however there are many considerations that need to be thought of. For more information, see the *API Design Considerations* section of this guide.

> There is currently a limitation that disallows use of abstract classes as `SpinnakerExtensionPoint`s: Use interfaces only.

### Remote Extension Points

**TODO**
- Configuration
- Transports (HTTP)
- Lifecycle
- Retrofitting existing code for remote

## API Design Considerations

### In-Process Considerations

**TODO**

### Remote Considerations

**TODO**

## Integrating Service Extension Points

Extensions will be exposed into the application much the same way any other component will be, however there are some notes specifically on dependency injection.

### Dependency Injection

Extensions that implement your `ExtensionPoint` will be available for dependency injection within your service. However, because the plugin framework initializes plugins (and therefore extensions) late in the application lifecycle, it is often too late to auto-wire a `List<MyExtensionPoint>` into a service component. Furthermore, remote plugins' extensions will likely be registered after a service starts up, and may create extensions long after service startup that need to be resolved. 

There are currently 3 dependency injection options available:

1. `ObjectProvider`
2. `ApplicationEventListener`
3. A `Registry`

#### `ObjectProvider`

The `ObjectProvider`, and its superclass `Provider`, are a way of lazily resolving class dependencies. Often times, these types are used for breaking up circular dependency chains, but you can also use them for referencing extension points.

```kotlin
@Component
class MyServiceComponent(
  val extensions: ObjectProvider<List<MyExtensionPoint>>
) {

  fun doingSomeBusiness() {
    extensions.stream().peek { it.doStuff() }
  }
}
```

#### Events

The plugin framework emits an `ExtensionCreated` application event whenever an extension is initialized and injected into the service `ApplicationContext`. Your service components can listen for these events to update internal caches. This is the preferred method any time additional processing needs to occur on extensions before use within a component, as processing will only happen during write access, rather than on read access.

```kotlin
@Component
class MyServiceComponent(
  private val extensions: MutableList<MyExtensionPoint> = mutableListOf()
) {

  @EventListener(ExtensionCreated::class)
  private fun onExtensionCreated(e: ExtensionCreated) {
    extensions.add(e.bean)
  }

  fun doingSomeBusiness() {
    extensions.forEach { it.doStuff() }
  }  
}
```

Alternatively:

```kotlin
@Component
class MyServiceComponent(
  private val extensions: MutableList<MyExtensionPoint> = mutableListOf()
) : ApplicationEventListener<ExtensionCreated> {

  override fun onApplicationEvent(e: ExtensionCreated) {
    extensions.add(e.bean)
  }
}
```

#### A `Registry`

Plugins could be offered a custom `Registry` class for them to decide what extensions they want to register into the service. This pattern is a little more hands-on for plugin developers, and does tend to force extensions to be in-process, but there may be valid use cases when the other options will not work.

```kotlin
@Component
class MyExtensionPointRegistry {
  internal val extensionPoints: MutableList<MyExtensionPoint>

  fun register(extension: MyExtensionPoint) {
    extensionPoints.add(extension)
  }
}

class MyServiceComponent(
  private val registry: MyExtensionPointRegistry
) {

  fun doingSomeBusiness() {
    registry.extensions.forEach { it.doStuff() }
  }
}
```

Plugin code:

```kotlin
@SpinnakerExtension
class MyExtension(
  private val registry: MyExtensionPointRegistry
) : MyExtensionPoint {
  init {
    registry.register(this)
  }
}
```

### Jackson Mixins

In many cases, serialization of extension point objects may be needed. Jackson (and similar serialization libraries) are illegal within the API module, but fortunately [Jackson Mixins](https://github.com/FasterXML/jackson-docs/wiki/JacksonMixInAnnotations) can be used to circumvent this limitation and still get full control over serialization via annotations.

As an example, we'll use Keel's `ResourceKind` type, as defined in `keel-api`:

```kotlin
data class ResourceKind(
  val group: String,
  val kind: String,
  val version: String
)
```

In `keel-core`, a `ResourceKindMixin` interface is defined:

```kotlin
@JsonSerialize(using = ToStringSerializer::class)
@JsonDeserialize(using = ResourceKindDeserializer::class)
interface ResourceKindMixin
```

And then finally linked together by a the `KeelApiModule` (a Jackson `Module` subtype):

```kotlin
object KeelApiModule : SimpleModule("Keel API") {
  override fun setupModule(context: SetupContext) {
    setMixInAnnotations<ResourceKind, ResourceKindMixin>()
  }
}

internal inline fun <reified TARGET, reified MIXIN> SetupContext.setMixInAnnotations() {
  setMixInAnnotations(TARGET::class.java, MIXIN::class.java)
}
```

While this specific example exhibits setting custom serializer / deserializer classes for the type, `@JsonProperty` and other annotations are also available for use on the `interface` mixin. Following this pattern, you will be able to fully customize serialization while keeping Jackson out of the API module classpath completely.

## Testing Extension Points

There are four areas of testing when developing extension points:

1. Unit tests of extension types and supporting classes.
2. Development of Plugin TCKs (Technology Compatibility Kit) 
3. Service Plugin Tests
4. Service Unit Tests

Of these, 1 and 4 should be immediately familiar: Firstly, we need to test the extension point code (if any exists) in the service API module's `test` source set. And fourth, we need to ensure the service has tests around the areas where extension points are both loaded and invoked.

Plugin TCKs and Plugin Tests, however, are specific concepts for enabling stable plugin extension points.

### Plugin TCKs (Technology Compatibility Kit)

Plugin developers need a way of asserting their plugin will work when installed into a service. Plugin TCKs are for this purpose: They are artifacts plugin developers use to unit test their plugins. TCKs can and should include tests as well as any test helpers and DSLs to reduce manual toil in writing tests.

Every service has a baseline suite of TCK tests that plugin developers can use, and also include a harness for starting the plugin under test within an in-memory version of the service. All TCK suites are found in `{service}-api-tck` (called "*the TCK module*"). 

When building a new `SpinnakerExtensionPoint`, it is highly recommended to offer some baked-in tests developers can use to assert against a contract greater than just the API.

An example of some TCKs can be found in the plugin framework for validating enabled and disabled plugins via `[PluginsTck](https://github.com/spinnaker/kork/blob/master/kork-plugins-tck/src/main/kotlin/com/netflix/spinnaker/kork/plugins/tck/PluginsTck.kt)`.

### Service Plugin Tests

On the other side of Plugin TCKs, Service Plugin Tests allow you to write dummy plugins into the service for testing. These plugins are compiled at runtime, and can be constructed programmatically as needed. These suite of tests are particularly useful for performing integration tests of extension points, and testing for specific use cases / bug fixes.

These tests are located in `{service}-plugin-tests` modules.

> There is currently no official support for multi-service plugin integration tests.
