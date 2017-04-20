---
layout: single
title: "Writing a New Stage"
sidebar:
  nav: guides
---

{% include toc %}

To create a new stage, you need to make backend changes to 
[orca](https://github.com/spinnaker/orca) to implement the logic of the stage,
and the front-end changes to [deck](https://github.com/spinnaker/deck) to
implement the UI. Depending on what the stage does, you may need to implement
new cloud provider-specific logic into [clouddriver](https://github.com/spinnaker/clouddriver) as well.

This doc currently only covers the backend changes made to orca.

# Backend (orca)

For the backend, you need to define:

* A stage class
* One or more task classes associated with the stage

## Stage Class

A stage class must implement the [com.netflix.spinnaker.orca.pipeline.StageDefinitionBuilder](https://github.com/spinnaker/orca/blob/master/orca-core/src/main/groovy/com/netflix/spinnaker/orca/pipeline/StageDefinitionBuilder.java) interface.

For providing additional functionality, it can also implement other interfaces:

* A **CancellableStage** can be cancelled.
* A **RestartableStage** can be restarted.
* A **CloudProviderAware** stage exposes information about the cloud provider.
* An **AuthenticatedStage** can perform custom authentication.

Here's an example based on a stage that is used internally at Netflix to
integrate with the Chaos Automation Platform (ChAP).

The stage is composed of two tasks:

* `beginChap` starts a new ChAP run
* `monitorChap` waits for the ChAP run to finish

```java
package com.netflix.spinnaker.orca.pipeline;

import com.google.common.collect.ImmutableMap;
import com.netflix.spinnaker.orca.CancellableStage;
import com.netflix.spinnaker.orca.chap.ChapService;
import com.netflix.spinnaker.orca.chap.Run;
import com.netflix.spinnaker.orca.chap.tasks.BeginChapTask;
import com.netflix.spinnaker.orca.chap.tasks.MonitorChapTask;
import com.netflix.spinnaker.orca.pipeline.model.Execution;
import com.netflix.spinnaker.orca.pipeline.model.Stage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class ChapStage implements StageDefinitionBuilder, CancellableStage {

  @Autowired
  public ChapService chapService;

  @Override
  public <T extends Execution<T>> void taskGraph(Stage<T> stage, TaskNode.Builder builder {
    builder
      .withTask("beginChap", BeginChapTask.class)
      .withTask("monitorChap", MonitorChapTask.class);
  }

  @Override
  public CancellableStage.Result cancel(Stage stage) {
    Run run = (Run) stage.getContext().get("run");
    if (run != null) {
      Run latestDetails = chapService.cancelChap(run.id.toString(), "");
      return new CancellableStage.Result(stage, ImmutableMap.of("run", latestDetails));
    }

    return null;
  }
}
```

## Task Classes

A task class must implement a [com.netflix.spinnaker.orca.Task](https://github.com/spinnaker/orca/blob/master/orca-core/src/main/groovy/com/netflix/spinnaker/orca/Task.java), 
or an interface that extends it, such as:

* A **RetryableTask** can be retried if it fails.
* A **PreconditionTask** defines preconditions that the task will enforce.

To communicate that a task failed, throw a `RuntimeException`.

In our example, the `ChapStage` consists of two tasks:

1. `BeginChapTask`
1. `MonitorChapTask`

### BeginChapTask

The `BeginChapTask`:

1. retrieves the `testCaseId` specified by the suer during the task configuration stage
1. calls the ChAP service via REST API call (see `ChapService.startChap`)
1. returns a `DefaultTaskResult`, passing it the response from the ChAP REST API call

```java
package com.netflix.spinnaker.orca.chap.tasks;

import com.netflix.spinnaker.orca.*;
import com.netflix.spinnaker.orca.chap.ChapService;
import com.netflix.spinnaker.orca.chap.Run;
import com.netflix.spinnaker.orca.pipeline.model.Stage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Component
public class BeginChapTask implements RetryableTask {

  @Override
  public TaskResult execute(Stage stage) {
    Map<String, Object> ctx = stage.getContext();
    Object testCaseId = ctx.get("testCaseId");

    if(testCaseId == null || !(testCaseId instanceof String)) {
      throw new RuntimeException("Cannot begin ChAP experiment without a testCaseId.");
    }

    Map<String, Object> params = new HashMap<>();
    params.put("testCaseId", testCaseId);
    Run chapRun = chapService.startChap(params);

    Map<String, Object> map = new HashMap<>();
    map.put("run", chapRun);
    return new DefaultTaskResult(ExecutionStatus.SUCCEEDED, map);
  }

  public ChapService getChapService() {
    return chapService;
  }

  public void setChapService(ChapService chapService) {
    this.chapService = chapService;
  }

  @Autowired
  private ChapService chapService;

  @Override
  public long getBackoffPeriod() {
    return TimeUnit.SECONDS.toMillis(5);
  }

  @Override
  public long getTimeout() {
    return TimeUnit.MINUTES.toMillis(1);
  }
}
```

### MonitorChapTask

The `MonitorChapTask` polls the ChAP service for the status of the ChAP run.

```java
package com.netflix.spinnaker.orca.chap.tasks;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.netflix.spinnaker.orca.DefaultTaskResult;
import com.netflix.spinnaker.orca.ExecutionStatus;
import com.netflix.spinnaker.orca.RetryableTask;
import com.netflix.spinnaker.orca.TaskResult;
import com.netflix.spinnaker.orca.chap.ChapService;
import com.netflix.spinnaker.orca.chap.Run;
import com.netflix.spinnaker.orca.pipeline.model.Stage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Component
public class MonitorChapTask implements RetryableTask {

  @Autowired
  private ObjectMapper objectMapper;
  
  @Autowired
  public ChapService chapService;

  @Override
  public TaskResult execute(Stage stage) {
    Map<String, Object> ctx = stage.getContext();

    Run run = objectMapper.convertValue(ctx.get("run"), Run.class);

    if (run == null) {
      throw new RuntimeException("Cannot monitor Chap task without a valid Run in the context.");
    }

    Run latestDetails = chapService.getChap(run.id.toString());

    Map<String, Object> map = new HashMap<>();
    map.put("run", latestDetails);

    if(latestDetails.outcome == Run.Outcome.PASSED){
      return new DefaultTaskResult(ExecutionStatus.SUCCEEDED, map);
    }

    ExecutionStatus status;

    switch (latestDetails.state) {
      case COMPLETED:
        //workflow is complete, but the outcome didnt pass, consider this a failure.
      case FAILED:
        throw new RuntimeException("ChAP experiment failed.");
      case CANCELLED:
        status = ExecutionStatus.CANCELED;
        break;
      default:
        status = ExecutionStatus.RUNNING;
        break;
    }


    return new DefaultTaskResult(status, map);
  }

  public ChapService getChapService() {
    return chapService;
  }

  public void setChapService(ChapService chapService) {
    this.chapService = chapService;
  }

  @Override
  public long getBackoffPeriod() {
    return TimeUnit.MINUTES.toMillis(1);
  }

  @Override
  public long getTimeout() {
    return TimeUnit.DAYS.toMillis(1);
  }

  public ObjectMapper getObjectMapper() {
    return objectMapper;
  }

  public void setObjectMapper(ObjectMapper objectMapper) {
    this.objectMapper = objectMapper;
  }
}
```

## Other Classes Used

The details of the `com.netflix.spinnaker.orca.chap.Run` class and 
`com.netflix.spinnaker.orca.chap.ChapService` interface aren't directly relevant 
to learning how to write a Spinnaker stage, but for completeness, here's what 
those look like for this case:

### Run

The `Run` class is a Java object that is deserialized from JSON.

```java
package com.netflix.spinnaker.orca.chap;

import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Run {

  public UUID id;
  // Other properties not shown
  // ...

  // Support arbitrary properties without needing to define them explicitly
  public Map<String, Object> properties = new HashMap<>();

  @JsonAnySetter
  public void set(String fieldName, Object value) {
    this.properties.put(fieldName, value);
  }

  @JsonAnyGetter
  public Object get(String fieldName) {
    return this.properties.get(fieldName);
  }
}
```

### ChapService

The `ChapService` defines a REST client API for talking to the ChAP service. It
uses the [Retrofit](https://square.github.io/retrofit) library.

```java
package com.netflix.spinnaker.orca.chap;

import retrofit.http.Body;
import retrofit.http.GET;
import retrofit.http.POST;
import retrofit.http.Path;

import java.util.Map;

public interface ChapService {
  @POST("/v1/runs")
  Run startChap(@Body Map params);

  @GET("/v1/runs/{id}")
  Run getChap(@Path("id") String id);

  @POST("/v1/runs/{id}/stop")
  Run cancelChap(@Path("id") String id, @Body String body);
}
```

### ChapConfig

To implement the `ChapService` interface, we do not define a class that extends
the interface. Instead, we define a class named `ChapConfig` with a Spring
`@Configuration` annotation. Note that this implementation uses the `chap.baseUrl`
configuration value that is defined in a separate Spinnaker configuration file.

```java
package com.netflix.spinnaker.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.netflix.spinnaker.orca.chap.ChapService;
import com.netflix.spinnaker.retrofit.Slf4jRetrofitLogger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import retrofit.Endpoint;
import retrofit.RestAdapter;
import retrofit.client.Client;
import retrofit.converter.JacksonConverter;

import static retrofit.Endpoints.newFixedEndpoint;

@Configuration
@ComponentScan({
  "com.netflix.spinnaker.orca.chap.pipeline",
  "com.netflix.spinnaker.orca.chap.tasks"
})
@ConditionalOnProperty(value = "chap.baseUrl")
public class ChapConfig {

  @Bean
  Endpoint chapEndpoint(@Value("${chap.baseUrl}") String chapBaseUrl) {
    return newFixedEndpoint(chapBaseUrl);
  }

  @Bean
  ChapService chapService(Endpoint chapEndpoint, 
                          Client retrofitClient, 
                          RestAdapter.LogLevel retrofitLogLevel, 
                          ObjectMapper objectMapper) {
    return new RestAdapter.Builder()
      .setEndpoint(chapEndpoint)
      .setClient(retrofitClient)
      .setLogLevel(retrofitLogLevel)
      .setLog(new Slf4jRetrofitLogger(ChapService.class))
      .setConverter(new JacksonConverter(objectMapper))
      .build()
      .create(ChapService.class);
  }
}
```
