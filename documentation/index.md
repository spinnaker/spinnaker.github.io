---
title:  "Documentation"
sidebar:
  nav: documentation
---

{% include toc %}


This document provides an overview of how Spinnaker is configured and
how to customize it for your particular deployment.

## Overview of Spinnaker configuration

Spinnaker is composed of microservices, each of which can be configured independently. In order to facilitate system-wide configuration, a master configuration file provides the key parameters from a global spinnaker perspective, which should meet most typical needs.

Spinnaker uses Spring to configure itself. Technically this means that there are lots of different ways and places to configure Spinnaker. However, it is not necessary to worry about the intricacies and details of Spring, nor will this guide discuss Spring or its mechanics.

This document assumes spinnaker is being run from installed packages. Developer builds run from source code use different locations for the configuration files (discussed at the end of this document).


### Types of configuration files

The complete realm of configuration possibilities spans a lot of files in a lot of locations. For practical purposes the critical files you will be concerned with are:
* Spinnaker's default `*.yml` files in `/opt/spinnaker/config`.
* Your customized `*-local.yml` files in `/opt/spinnaker/config`.
* Provider platform credential files you provide and deposit, typically under `$HOME` or `/opt/spinnaker/config` but may vary depending on what the credentials are for.
* The default installation of Spinnaker will run as the user `spinnaker`, whose `$HOME` is `/home/spinnaker`.


### About notation used within the YAML files

The YAML files define hierarchical name value pairs. The values can be indirect using the notation `${property}` or `${property:default}` where `property` is the name of the property whose value is being referenced and `default`, if provided, is the value to use if *property* cannot be found. Technically, the *property* uses Spring to resolve the value. But in practice these will usually resolve to properties specified elsewhere in the YAML or as environment variables. By convention, environment variables are typically upper case and separated with underscores (e.g. `SOME_ENV_VAR`) as opposed to other properties within the YAML that are lower case and separated with dots (e.g. `domain.component.attribute`).

The standard practice within Spinnaker is that the *subsystem*`.yml` files will specify their configuration by referencing properties defined in `spinnaker.yml` for standard system-wide values and policies, and inline literal values for values that are local, encapsulated, or non-standard overrides.

The `spinnaker.yml` file defines two hierarchies of properties (described later), neither of which are directly used to configure the microservice subsystems. Rather these are used for those system configurations to explicitly acknowledge how and where they are using the standard configuration values, since they always include the `spinnaker.yml`.

You can completely rewrite the *system*`.yml` files and forget about `spinnaker.yml`, however this will become tedious to maintain in a consistent way.


### About the different YAML files

The YAML configuration files are named *system*`.yml` where system is `spinnaker` or one of its subsystems (as described later). By default they are located in `/opt/spinnaker/config`. However, there is a default search path used to look for files. The gist is that each subsystem looks in the `/opt/spinnaker/config` directory for files named either `spinnaker.yml`, *subsystem*`.yml`, `spinnaker-local.yml`, or *subsystem*`-local.yml`.

By convention the `-local.yml` files override standard configuration to customize the local deployment, thus these are the preferred files you will be editing. The non `-local.yml` files are intended to be the standard default configuration shipped with each Spinnaker release. Since `-local.yml` files are specific deployment customizations, Spinnaker does not ship with any. And since
it does not ship with any, your files will be preserved without conflict when you update Spinnaker in the future, and the default configuration files should be easy to update to the future version since they were never modified.

The files are included in a particular order where individual properties in later files will override the entries in earlier files. If some properties are overriden but not others, then all the properties will still be present but their values will have come from different files.

Files are included in the following order:

  1. `spinnaker.yml`
  2. `spinnaker-local.yml`
  3. *subsystem*`.yml`
  4.  *subsystem*`-local.yml`


### Anatomy of YAML files

As noted earlier, each Spinnaker subsystem loads both the `spinnaker.yml` and *subsystem*`.yml` files (and their `-local.yml` overrides). This means that every subsystem will be loading the same `spinnaker.yml` file plus a unique *subsystem*`.yml`, where the unique file has higher precedence. By convention, the unique *subsystem*`.yml` file defines all the configuration parameters that the subsystem uses, but sets their values indirectly from the standard systemwide values maintained in `spinnaker.yml`.

## Enumeration of YAML configuration files

**spinnaker.yml**

The `spinnaker.yml` contains two hierarchies of properties.

1. `provider` is used for provider-specific values.
  * The children of `provider` are the different cloud platform providers that Spinnaker defaults.
  * Each `provider` tree contains the properties that are needed for that particular platform's integration. By definition, these vary from platform to platform and are only used in the context of that platform.
  * The `provider.`*platform*`.primaryCredentials` root holds different properties used to define the default account and credentials needed when managing that platform. Spinnaker permits multiple accounts so that it can manage resources on behalf of different accounts. The primary account is referenced to configure the different *subsystem*`.yml` needs from a single place in `spinnaker-local.yml` and meets the needs of a single-account deployment.
  * Additional credential configuration will go in `clouddriver.yml`. The actual credentials for all accounts (including primary) are typically stored externally in protected files, but exactly where and how depends on the individual platform.

2. `services` is used for Spinnaker subsystem and service-specific values.
  * The children of `services` are the individual services. Each service contains the minimal properties needed by consumers of the service (so they can share the configuration through the common standard `spinnaker.yml`) and typically key configuration parameters for convenience of having the `spinnaker-local` act as a single source configuration file.
  * Most if not all services share common property names by convention.
       * `host` defines the IP host for the service endpoint.
       * `port` defines the IP port for the service endpoint.
       * baseUrl defines the HTTP service endpoint. The default is typically composed from `host` and `port`.
       * The expectation is that the *subsystem*`.yml` will bind the IP address it listens on by referencing `${services.`*subsystem*`.host}` and `${services.`*subsystem*`.port}`, where consumers will connect to it by referencing `${services.`*subsystem*`.baseUrl}`.
   * A special entry `default` contains default values used solely to reference other default values.
       * `services.default.host` is the default `host` to use. This is `localhost` by default indicating that all the services by default will bind to the loopback address so as not to expose themselves to external addresses. This could be changed to 0.0.0.0 or a public IP or DNS alias for the localhost to expose the services to other machines.
       * `services.default.primaryAccountName` is the default account to use where a configuration needs credentials for internal usage, for example, the bakery. This is expected to reference one of the provider's `primaryAccount.name` properties, particularly where there are multiple providers.

**default-spinnaker-local.yml**

This file is not actually used by Spinnaker. If you wish to create a `spinnaker-local.yml`, copy this file instead of `spinnaker.yml` before editing it.

**clouddriver.yml**

Clouddriver is responsible for the platform integration so this is likely where you will find platform-specific configuration options. Clouddriver is also responsible for managing the platform credentials.

**echo.yml**

Echo is responsible for messaging. Among other things, all the notification services are configured here.

**front50.yml**

Front50 mediates Spinnaker's persistent data store.

**gate.yml**

Gate acts as a gateway server to present the different Spinnaker subsystems as a single endpoint. There's probably nothing to specialize here since gate is essentially mediating the other services.

**igor.yml**

Igor provides integration with Jenkins. If you are going to add additional Jenkins servers beyond the default specified in the `spinnaker-local.yml` then this is where to specify them.

**orca.yml**

Orca provides the workflow orchestration within Spinnaker.

**rosco.yml**

Rosco implements Spinnaker's bakery. Most of the configuration is pulled from `spinnaker.yml`

## Additional configuration files

**/etc/default/spinnaker**

The environment variables referenced by `spinnaker.yml` are maintained in `/etc/default/spinnaker`. These environment variables are not directly used by Spinnaker. They are only used to resolve the default YAML values. There is nothing particularly special about these, but these are typically populated during automated installation and setup for convenience.

**/var/www/settings.js**

Deck, Spinnaker's web interface, provides its settings in this javascript file rather than YAML files like the others.

This file is generated from `/opt/spinnaker/config/settings.js` using the script `/opt/spinnaker/bin/reconfigure_spinnaker.sh`.

By convention there is a collection of variables in a section near the top of the file that the `reconfigure_spinnaker.sh` script uses to sync the javascript from the shared Spinnaker YAML. If you are extending the web interface and want to add another configuration parameter simply add another comment to the reconfigure_spinnaker block in the file following the existing convention.

**$HOME/.aws/credentials**

This is a standard AWS credentials file used by Spinnaker to interact with AWS.

**Google Credential Files**

Google uses JSON credential files downloaded via the [Google Developers Console (https://console.developers.google.com/project/_/apiui/credential). These files can be anywhere, but are typically put in `$HOME/.spinnaker`. In order to configure Spinnaker to use these files, you must set the `jsonPath` attribute in the Google credentials associated with the project whose resources you wish to manage using those credentials. This is typically in the `spinnaker-local.yml` file. However, if you are managing multiple accounts, then the account collection will be managed in `clouddriver-local.yml`.


## Dependency Configuration

Spinnaker implicitly depends on Redis and Cassandra. These systems are not typically documented or discussed in the Spinnaker documentation. However, you may need to configure these systems directly.


# Configuring Developer Builds

When Spinnaker is run using the developer script `./spinnaker/dev/run_dev.sh` out of the source, then it will look in `$HOME/.spinnaker` and the `./spinnaker/config` directory in the source tree rather than `/opt/spinnaker/config`. It will *not* consider the `/etc/spinnaker/default` file containing environment variables. Developer build configuration is encapsulated to the user and source tree, not global machine state. If you want environment variables, you must set them yourself.


# Spring Boot Configuration Details

This section provides an alternative perspective from the Spring implementation point of view.

To see some use cases for overrides, see below.

# Use Cases

Here are some situations you may run into and a way to work through it. NOTE: It's possible to combine use cases.

## Use case 1: Can I stick my super secret credentials in there somewhere?

Try to avoid that!! Secrets are meant to stay secret. Instead, see if you can either supply credentials through environment variables, or configure a separate property file that isn't put under source control.

## Use case 2: &lt;module>.yml just doesn't cut it

An excellent example is `clouddriver.yml` which lists accounts to talk to. In Cloud Foundry, if you have more than one account to wire, you'll want to create a `clouddriver-local.yml` file to override the single account setting provided by default. Local is a profile automatically added, giving you space to write an override.

## Use case 3: I need my config files somewhere unique

Put them where you need them and run things with `spring.config.location` (or `SPRING_CONFIG_LOCATION`) pointed at your alternate path.

## Use case 4: Property inheritance doesn't fit my needs

At the end of the day, you can simply write your own set of module-specific YAML files and not reference any properties from `spinnaker.yml`.

# How Spinnaker resolves properties

Spinnaker is highly customizable thanks to externalized property settings. This means that the various URLs, ports, and configuration settings to talk to your Spinnaker environment as well as the place your deployments are sent, are adjustable.

This is done using Spring Boot's [externalized property settings](http://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-external-config).

Look at the following code from Spinnaker:

```
@Component
@ConditionalOnProperty('slack.enabled')
class SlackNotificationService implements NotificationService {
  private static Notification.Type TYPE = Notification.Type.SLACK

  @Autowired
  SlackService slack

  @Value('${slack.token}')
  String token
  ...
```

Assume that you are configuring echo.

There are two properties listed: `slack.enabled` and `slack.token`. These are properties that dictate whether or not this part of [echo](https://github.com/spinnaker/echo) is enabled or not, and if so, what the token value is to connect it to a slack webhook.

The `@Value` annotation is a core component of the Spring Framework that has been available for years, and `@ConditionalOnProperty` is from Spring Boot, allowing components, services, etc. to optionally by activated.

Spring Boot has an order it follows when trying to resolve property values.

1. It looks for a default value right in the annotation. `@Value("${slack.token:my-default-value}")` would be the way to specify **my-default-value** in the code.

2. Spring Boot will look for overrides in the application's `echo.yml` and `spinnaker.yml` files that are bundled up in its JAR file.

 > **NOTE:** Spring Boot actually looks for `application.yml` and `application-${profile}.yml` files. But the value `application` is overridden in Spinnaker using `spring.config.name=echo,spinnaker`. This lets each module put all their configuration files in one folder without conflict while also reading from a common superset of properties in `spinnaker.yml` (and its variants).

3. Spring Boot will then look for any overrides tied to a specific **profile**. Profile-specific property files look like `echo-${profile}.yml`.

 > **QUESTION:** What's a profile? A profile is a collection of properties tied to a specific environment. For example, you could have **dev**, **test**, and **production**. You can have more than one profile active at any given time. These are activated by setting `spring.profiles.active`. For example you could apply `spring.profiles.active=cloud,production` to your setup. That would cause echo, in this situation, to look for `echo-cloud.yml` and `echo-production.yml` for options to override any previous properties.

4. By default, Spring Boot looks inside the JAR file as well as adjacent to the JAR file for property files. But you can also tell Boot to look in other places by overriding `spring.config.location`. Spinnaker has each module configured to look in `$HOME/.spinnaker` in its source code, and the build scripts provide other options, such as `/opt/spinnaker/config`. If you are setting up Spinnaker and want to locate all your configuration settings somewhere else, just override that setting.

5. Spring Boot will also look for any environment variables that override property settings by inspecting environment variables. Environment variables can be supplied to a JVM process using `-D`. For example, `java -Dslack.token=secret -jar myapp.jar` would feed Spring Boot an environmental override for that property. To make things flexible for multiple platforms, Spring Boot supports [relaxed bindings](http://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-external-config-relaxed-binding). This means that `SLACK_TOKEN` and `slack.token` will both resolve to `@Value("${slack.token}")`. Hence, `SLACK_TOKEN=secret java -jar myapp.jar` will also work.

 > **NOTE**: Environment variables are handy for certain environments like Cloud Foundry where you may not have access to either the local filesystem to drop an adjacent property file nor be able to add an extra argument to the JRE. Cloud Foundry allows you to apply environment properties to any application, giving you the power to override any property.

# Why is this so hard?!?

Well, you are talking about linking together multiple processes in a highly customizable way. This mechanism lets the Spinnaker team roll out a base configuration while still giving you maximum power to tweak every single setting. The trade off for such flexibility is having to embrace all these moving parts. If you find any issues, [let us know](https://github.com/spinnaker/spinnaker/issues).
