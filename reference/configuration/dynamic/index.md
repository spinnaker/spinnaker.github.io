---
layout: single
title:  "Dynamic Configuration"
sidebar:
  nav: reference
---

{% include toc %}

This page describes Spinnaker's dynamic configuration feature. Using dynamic configuration, you can manage account configuration (either complete account configuration, or only secrets such as account passwords) externally from Spinnaker.

Dynamic configuration uses the open-source [Spring Cloud Config](https://spring.io/projects/spring-cloud-config) project, which includes a configuration server and client libraries to support centralized external configuration in a distributed system. The Config Server connects to a remote configuration repository and serves stored configuration properties to client applications. Configuration properties can be organized by Spring profile and application name and can be stored in any of a number of backends, including Git, HashiCorp Vault, JDBC, CredHub, and others. For more information about Spring Cloud Config, see the [documentation](https://cloud.spring.io/spring-cloud-static/spring-cloud-config/2.1.0.RELEASE/single/spring-cloud-config.html).

The following table lists the Spinnaker services that currently incorporate dynamic configuration.

| Service     | Account Types            | Notes                                                                                                          |
|-------------|--------------------------|----------------------------------------------------------------------------------------------------------------|
| Clouddriver | Cloud provider, artifact | Automatic configuration refreshing is supported for Cloud Foundry and Kubernetes cloud provider accounts only. |
| Echo        | Pub/Sub                  |                                                                                                                |
| Igor        | CI system                |                                                                                                                |

## Enabling dynamic configuration

To enable dynamic configuration via the Config Server, add Spring Cloud Config configuration properties, which are under `spring.cloud.config.server`, and include settings for the backend you wish to use. If you deploy Spinnaker manually, you might place this configuration in a YAML file called `spinnakerconfig.yml`, alongside your `spinnaker.yml` file.

To use a Git backend, configure the settings under `spring.cloud.config.server.git`. Your configuration might look like the following example:

```yml
spring:
  profiles:
    include: git
  cloud:
    config:
      server:
        git:
          uri: https://github.com/example/spinnaker-config
          refresh-rate: 10
```

To use a HashiCorp Vault backend, configure the settings under `spring.cloud.config.server.vault`. Your configuration might look like the following example:

```yml
spring:
  profiles:
    include: vault
  cloud:
    config:
      server:
        vault:
          host: config-vault.example.com
          port: 8200
          backend: secret
          kvVersion: 2
          default-key: clouddriver
          token: [vault access token]
```

For information about configuring other supported Config Server backends, see the [Spring Cloud Config Server documentation](https://cloud.spring.io/spring-cloud-static/spring-cloud-config/2.1.0.RELEASE/single/spring-cloud-config.html#_environment_repository).

## Managing dynamic configuration

You can use the Config Server to dynamically manage all of your account configuration (bypassing Halyard), or to manage secrets used by Halyard account configuration. You can also use the Config Server to retrieve configuration files or encrypted configuration properties.

### Complete account configuration

If you wish to use dynamic configuration instead of Halyard to store complete configuration for your accounts, you can move the account configuration to files stored in a Config Server backend, such as a Git repository or HashiCorp Vault server.

To store complete account configuration in Git, create a Git repository and within it, place a file named `spinnaker.yml`. The file should contain the account configuration, as in the following example:

```yml
cloudfoundry:
  enabled: true
  accounts:
    - name: foundation1
      user: admin
      password: 'secret1'
      api: api.sys.foundation1.example.com
      appsManagerUri: https://apps.sys.foundation1.example.com
    - name: foundation2
      user: admin
      password: 'secret2'
      api: api.sys.foundation2.example.com
      appsManagerUri: https://apps.sys.foundation2.example.com
```

To store complete account configuration in HashiCorp Vault, create a JSON file (for example, `clouddriver.json`) containing the account configuration, as in the following example:

```json
{
  "cloudfoundry": {
    "enabled": true,
    "accounts": [
      {
        "name": "foundation1",
        "user": "admin",
        "password": "secret1",
        "api": "api.sys.foundation1.example.com",
        "appsManagerUri": "https://apps.sys.foundation1.example.com"
      },
      {
        "name": "foundation2",
        "user": "admin",
        "password": "secret2",
        "api": "api.sys.foundation2.example.com",
        "appsManagerUri": "https://apps.sys.foundation2.example.com"
      }
    ]
  }
}
```

Then use the `vault` command-line interface tool to store this JSON in Vault: 

```bash
$ vault kv put secret/clouddriver @clouddriver.json
```

### Secrets

If you wish to use Halyard to manage account configuration but store secrets (such as account passwords) externally, you can move the account secrets into files stored in a Config Server backend, such as a Git repository or HashiCorp Vault server. You can then use Spring property placeholders to reference the secret values.

If you are configuring a Cloud Foundry cloud provider account, your `spinnaker.yml` file might look like the following example:

```yml
cloudfoundry:
  enabled: true
  accounts:
    - name: foundation1
      user: admin
      password: ${cloudfoundry.foundation1.password}
      api: api.sys.foundation1.example.com
      appsManagerUri: https://apps.sys.foundation1.example.com
    - name: foundation2
      user: admin
      password: ${cloudfoundry.foundation2.password}
      api: api.sys.foundation2.example.com
      appsManagerUri: https://apps.sys.foundation2.example.com
```

In the Config Server backend (such as a Git repository), the account secrets file might look like the following example:

```yml
cloudfoundry:
  foundation1:
    password: 'secret1'
  foundation2:
    password: 'secret2'
```

### Configuration files

The Kubernetes, Google Cloud, and App Engine cloud providers can load account information from files that are separate from the service YAML configuration. You can load these separate files dynamically using the Config Server's Resource abstraction. In the service YAML configuration, prefix a file path with `configserver:` to indicate that the file should be retrieved by the Config Server. 

If you are configuring a Kubernetes cloud provider account and want to load an external `kubeconfig.yml` file using Config Server, your account configuration might look like the following example:

```yml
kubernetes:
  enabled: true
  accounts:
    - name: default
      providerVersion: V2
      kubeconfigFile: configserver:kubeconfig.yml
      dockerRegistries:
        - accountName: dockerhub
          namespaces: []
      context: default
```

### Encrypted values

The Config Server can store encrypted secrets in its backend and decrypt the secret values when serving them to clients. You can use this to store encrypted Spinnaker account secrets in a Config Server backend (such as a Git repository).

To enable Config Server decryption, configure the encryption key in your `spinnaker-config-local.yml`, along with the Config Server backend configuration properties. You can configure the encryption key using properties under `encrypt`.

When using Config Server encryption or decryption, your configuration might look like the following example:

```yml
spring:
  profiles:
    include: git
  cloud:
    config:
      server:
        git:
          uri: https://github.com/example/spinnaker-config
          refresh-rate: 10
encrypt:
  key: mykey
```

For more information about using the Config Server's encryption and decryption features, see the [Spring Cloud Config Server documentation](https://cloud.spring.io/spring-cloud-static/spring-cloud-config/2.1.0.RELEASE/single/spring-cloud-config.html#_encryption_and_decryption). 

## Dynamic configuration refresh

If you have enabled [caching](https://www.spinnaker.io/setup/productionize/caching/), Spinnaker will refresh its external configuration automatically on the same time interval as the Clouddriver agent caches. When using the default in-memory caching, this interval defaults to 60 seconds. When using [Redis caching](https://www.spinnaker.io/setup/productionize/caching/configure-redis-usage/), you can configure this interval using the `redis.poll.intervalSeconds` property.
