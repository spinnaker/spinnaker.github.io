---
layout: single
title:  "Captain's Log: The State of Spinnaker"
sidebar:
  nav: community
github_events:
  image_path: assets/images/graphs/GithubEvents_graph.png
  alt: "Graph of Github Events Since Open-Sourced"
activity:
  image_path: assets/images/graphs/ActivityByRepo_graph.png
  alt: "Graph of Github Activity by Repository Since Open-Sourced"
pr_authors:
  image_path: assets/images/graphs/PRAuthorsUnique_graph.png
  alt: "Graph of Unique PR Authors Since Open-Sourced"
---

You may have heard [success stories](/success-stories/) of enterprises moving from brittle deployments to continuous delivery with Spinnaker:
* [Airbnb uses Spinnaker](https://techbeacon.com/app-dev-testing/how-airbnb-scaled-its-migration-continuous-delivery-spinnaker) to migrate from monolith to service-oriented architecture.
* [SAP leverages Spinnaker](https://blog.spinnaker.io/pipeline-redemption-how-spinnaker-is-shaping-delivery-excellence-at-sap-3b3c931b4f63?) on its mission to run the world better.
* [Pinterest boosts productivity with Spinnaker](https://devops.com/devops-chat-ci-cd-velocity-for-large-monolithic-services-with-pinterest/) as it pioneers visual discovery.
* [Mercari champions Spinnaker](https://speakerdeck.com/tcnksm/continuous-delivery-for-microservices-with-spinnaker-at-mercari) as a safeguard against deployment fear while releasing new services.
* [Salesforce adopted Spinnaker](https://engineering.salesforce.com/salesforce-speakers-at-spinnaker-summit-and-kubecon-2019-d968292fd681) to bake images for both Kubernetes and VMs, to support its complex delivery requirements.

### But what are the numbers? How big is the project? What’s the growth trajectory?

## Spinnaker's Trajectory

Our community began as a partnership between Netflix & Google, eager to share the benefits of Continuous Delivery. Now it's a vibrant OSS project, attracting hundreds of companies to participate as it evolves, integrating unique use cases and tools. Behold!

{%
  include
  figure
  image_path="./stats-2020-02-05-with-logo.png"
%}



### GitHub Events in Spinnaker Repositories

After steadily building momentum since its first open-source release in 2015, Spinnaker activity takes off:
{%
  include
  figure
  image_path="./github_events.png"
%}

### Contributions Per Company

Building from a committed base of key organizations like Netflix, Google, Armory, OpsMx, and Amazon, 2019 saw significantly more contributions from end-user companies and new stakeholders:
{%
  include
  figure
  image_path="./company_contributions.png"
%}

### Activity By Repository

The Spinnaker ecosystem currently includes 44 repositories, including the microservices that deliver its core functionality and interface with deployment targets such as AWS, GCP, and Kubernetes. Also included: cleanup and monitoring tools, governance, community resources, and much more:
{%
  include
  figure
  image_path="./activity_by_repo.png"
%}

### Companies and Developers Contributing Each Week

Spinnaker has seen steadily increasing engagement from companies, and spikes of developer activity around community initiatives:
{%
  include
  figure
  image_path="./company_dev_count.png"
%}

### Myriad Pull Request Contributors

Unique authors contribute pull requests to Spinnaker repositories each week, building the project collaboratively over time.

{%
  include
  figure
  image_path="./pr_authors.png"
%}

### Visit Spinnaker DevStats for More!

The data presented here comes from [Spinnaker's DevStats Dashboard](https://spinnaker.devstats.cd.foundation/), an awesome project growth [visualization and monitoring tool](https://github.com/cncf/devstats) built by CNCF engineers in collaboration with Kubernetes and other CNCF project communities. DevStats defines a “contribution” as a review, comment, commit, PR, or issue. Big thanks to Lukasz Gryglicki and the CNCF!
