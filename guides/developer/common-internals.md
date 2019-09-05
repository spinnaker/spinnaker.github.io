---
layout: single
title: "Common Internals"
sidebar:
  nav: guides
---

Spinnaker is built as a collection of microservices, all of these services share a common foundation.
This page enumerates, at a high-level, what foundations the Spinnaker services are built atop.
You do not need to know all of these technologies to contribute, this page is meant more as a quick reference.

## Languages

Spinnaker is a collection of JVM backend-services and a frontend application (Deck).

- Deck
  - [TypeScript](https://www.typescriptlang.org/)
- Backend Services
  - [Kotlin](https://kotlinlang.org/)
  - Java + [Lombok](https://projectlombok.org/)

## Deprecated Languages

- [Groovy](https://groovy-lang.org/)

## Third-party Libraries

Spinnaker is built on the shoulders of giants. 
This is not an exhaustive list of libraries that we use, but the ones we've identified as having a large presence across the product.

- Deck
  - [React](https://reactjs.org/)
- Backend Services
  - Runtime
    - [gRPC](https://grpc.io/)
    - [Jackson](https://github.com/FasterXML/jackson)
    - [Jedis](https://github.com/xetorthio/jedis)
    - [jOOQ](https://www.jooq.org/)
    - [Keiko](https://github.com/spinnaker/keiko)
    - [Micrometer](http://micrometer.io/)
    - [OkHttp](https://square.github.io/okhttp/)
    - [Spring Boot 2](https://spring.io/projects/spring-boot)
    - [Resilience4j](https://resilience4j.readme.io/)
  - Testing
    - [Minutest](https://github.com/dmcg/minutest)
    - [Mockk](https://mockk.io/)
    - [Spock](http://spockframework.org/)
    - [Strikt](https://strikt.io/)
    - [Testcontainers](https://www.testcontainers.org/)

## Deprecated Third-party Libraries

Spinnaker is an ever-evolving system, and as such, so are the foundations we've chosen to build on top of.
These libraries still see extensive use within Spinnaker, however they have been deprecated in favor of another solution and the spread of their use is discouraged.

- Deck
  - [Angular](https://angularjs.org/): Actively migrating to React.
- Backend Services
  - [Hystrix](https://github.com/Netflix/Hystrix): Replaced by Resilience4j.
  - [Retrofit](https://square.github.io/retrofit/): Moving to gRPC. Where HTTP is required, converging on [Spring RestTemplate](https://spring.io/guides/gs/consuming-rest/).
  - [Spectator](https://github.com/Netflix/spectator): Replaced by Micrometer.
  - [Spek](https://spekframework.org/): Converging on Minutest + Strikt + Mockk.
