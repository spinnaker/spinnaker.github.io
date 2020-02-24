---
layout: single
title:  "*Flying*  Issue 1"
sidebar:
  nav: news
---


## Dear Spinnaker enthusiasts,

Hi! Welcome to the Spinnaker Newsletter, your source for info about the project and community. We'll focus on news for Spinnaker users, operators, and contributors.

### Spinnaker Summit 2019 (the best yet!)

We just wrapped an incredible Summit. In case you missed it (or want to replay each delicious moment) here’s a [reflection from the Armory blog](http://go.armory.io/keynote) and a video of [Isaac Mosquera's keynote](https://www.youtube.com/watch?v=BBdFOZASQ_4), along with recaps from OpsMX highlighting [5 key takeaways](https://blog.opsmx.com/spinnaker-summit-2019-recap/),  as well as [technical and feature takeaways](https://blog.opsmx.com/spinnaker-summit-2019-some-key-technical-takeaways/).

Along with many opportunities to connect, we found that attendees had numerous high-quality sessions to choose from. Apart from helpful accounts of enterprise Spinnaker adoption journeys, we also hosted discussions on:
* Learning from incidents and using Spinnaker to automate their resolution
* Service Mesh & Spinnaker
* Spinnaker Ops: provisioning w/ Terraform, debugging, monitoring, account mgmt, security
* [Secrets management](https://blog.armory.io/spinnaker-secrets-management-secrets-are-no-fun-when-you-share-with-everyone/)
* [Plugin framework](https://www.spinnakersummit.com/blog/how-armory-is-extending-spinnaker-for-the-enterprise)
* [Managed Delivery](https://blog.spinnaker.io/managed-delivery-evolving-continuous-delivery-at-netflix-eb74877fb33c) & Managed Pipeline Templates v2
* Experimentation using Canary analyses and more
* [Using custom stages for your CD and Kubernetes workflows](https://blog.spinnaker.io/running-jobs-stories-from-the-field-pt-1-4330e1e6ebb)

And much more! Access the [slides from all event presentations here](https://go.armory.io/spinsumslides). Look out for video, to be posted on YouTube and announced in [Spinnaker Slack](https://join.spinnaker.io/). Important discussions about the roadmap and future of Spinnaker also took place. Read more on that below!

---
### Spinnaker Roadmap

All eyes were on the [2020 roadmap](https://go.armory.io/spinmap) at the Summit, with themes of managed delivery, operator and developer experience, cloud-nativization, community, and runtime support on the brain. Dev workflows for those using K8S, the AWS clouddriver, Cloud Run, and Tekton figure prominently in H1, as do modern tools for managing Spinnaker: config-as-code approaches to provisioning, auto-generated docs, cloud integration tests, Prometheus monitoring, and more.

Version 1.17

Read the [release highlights](https://www.spinnaker.io/community/releases/versions/1-17-0-changelog). Notable feature adds include baseline git repo artifact support, and Kustomize support to leverage that new artifact type. In addition, Spinnaker now proudly supports Kubernetes’ new kubectl-initiated rolling restart capability, as well as isolation between multiple K8S V2 accounts. Also added: a more flexible auth model which allows Fiat to accept and resolve permissions from various sources.

---

### Spinnaker Evangelism Spotlight

We'll highlight Spinnaker evangelism here as users share love on the interwebs. In a *delightful* new Medium post, [Serge Poueme discusses SAPs evaluation and adoption of Spinnaker](https://blog.spinnaker.io/pipeline-redemption-how-spinnaker-is-shaping-delivery-excellence-at-sap-3b3c931b4f63). He praises the “digestible UI on the surface and .. controlled environment in the back end,” as well as the interoperability with Jenkins, Slack, and GitHub his teams enjoy as they take a developer-self-service approach to CD. My fave quote:

“When William found a bug, he determined the root cause and then proposed a fix via a pull request. Spinnaker responded swiftly, then provided further documentation for him to contribute to the project — another well-deserved high five to Spinnaker for being open source!”

You can say that again, Serge! He also boldly shares his feature requests, including a Halyard API for automation changes to Spinnaker instances, and better security, particularly around Docker image sourcing. His top request? Better documentation. Let’s put that on the agenda of the upcoming hackathon!

---
### Spinnaker Contributor Experience

As we invite users and contributors into the community, opportunities to unite on clear project goals and milestones arise. The TOC, SIG leads, and community advocates are working improve the Spinnaker contributor experience. If you have feedback about this, please share it at your next SIG meeting, and/or in the #community channel on [Spinnaker Slack](https://join.spinnaker.io/)
. Look out for experiments that aim to organize issues and improve your experience in advance of our first hackathon. Also: please be un-shy in filing issues. We have a particular need for first-hand “end-user”/developer feedback. Don’t be afraid to engage!

---
### CDF Strategic Goals

Netflix and Google donated Spinnaker to the [Continuous Delivery Foundation]https://go.armory.io/cdf) in March. The Foundation aims to tell the world the crucial story of CD, and to foster a vibrant community around it. From Spinnaker’s perspective, we want to improve collaboration amongst open-source partners, considering the importance of solution interoperability and clarity to our shared users (Jenkins, in particular, comes to mind here). Check out the strategic goals the CDF has charted for us:
* Drive continuous delivery adoption
* Cultivate, grow, and promote adoption of projects
* Foster Tool Interoperability
* Champion diversity & inclusion in our communities
* Foster community relations
* Grow the membership base
* Create value for all members
* Promote security as a first-class citizen
* Expand into emerging technology areas

Looking forward to working with the amazing Spinnaker community to realize these!
