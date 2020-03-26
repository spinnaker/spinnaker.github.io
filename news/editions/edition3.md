---
layout: single
title:  "*Flying*  Edition 3"
sidebar:
  nav: news
redirect_from: /news/latest/
---
## Open Source: #BetterTogether
> This month's issue focuses Spinnaker's strong open source DNA. Spinnaker builds a bridge between the collaboration story at the core of Linux culture and the powerful cloud economy that has leveraged it to transform software delivery. OSS community efforts to build native Kubernetes|Spinnaker integration highlight this unique strength.

## [The New Age of the K8S Operator](https://www.armory.io/blog/introducing-spinnaker-operator-a-kubernetes-native-blueprint-for-success/)
Spinnaker Operator, a Kubernetes operator for Spinnaker, has reached Beta. With it installed, you can use kubectl commands to install, deploy, upgrade, and manage any version of Spinnaker. Read the [doc](https://github.com/armory/spinnaker-operator/blob/release-0.3.x/README.md), try it out, and use the #kubernetes-operator channel in Spinnaker Slack to share your feedback.

## [Join Spinnaker Gardening Days #CommunityHack Virtually on April 9-10](https://github.com/spinnaker-hackathon/gardening)
Over 80 contributors and project newcomers have signed up for the first Spinnaker Gardening Days! We're collecting and discussing [project ideas here](https://github.com/spinnaker-hackathon/gardening/wiki/Project-Ideas). Socializing your ideas at this stage will help shape them into projects! Please visit the Wiki and join or create #gardening-idea Slack channels, and discuss with your peers. Alternatively, visit your favorite SIG's channel or meeting, and ask where you can jump in. Don't forget to [register](https://www.eventbrite.com/e/spinnaker-gardening-days-communityhack-tickets-97845696111) to reserve your ticket!

## [How to Build a Centos RPM Via a Spinnaker "Bake"](https://blog.opsmx.com/how-to-build-bake-centos-rpm-using-spinnaker/)
Spinnaker doesn't offer a CentOS baking option by default. In this tech blog, learn to use package management and S3 to bake a build as a CentOS image. Then, deploy an instance of the baked image on AWS cloud. With the RPM built, configuring and executing the bake in Spinnaker requires just a few steps.

## ['Just Me and Opensource' Tutorials Available on Youtube](https://www.youtube.com/watch?v=9EUyMjR6jSc&t=2s)
Fans of the __[Just me and Opensource](https://www.youtube.com/user/wenkatn)__ online tutorials got a nice dose of CD when the popular Youtuber published a new segment of his Kubernetes series focused on deploying Spinnaker to Kubernetes. Brilliant to learn hands-on how these open source software tools and technologies are better together.

## [Netflix's Interactive Slack Notifications for ChatOps with Spinnaker](https://blog.spinnaker.io/interacting-with-spinnaker-via-slack-at-netflix-9ab262e8218d)
2-way interactive Slack notifications allow Netflix engineers deploying with Spinnaker's new Managed Delivery feature to approve a Spinnaker pipeline manual judgement directly from Slack. Learn how Echo handles communications between notifying services and Slack via interactive notification callbacks.

## [Operating Spinnaker at Scale & the Ops SIG's Mission](https://www.armory.io/blog/scaling-spinnaker-at-salesforce-the-life-of-a-cloud-ops-architect/)
Discover the mission of the new Operations SIG in this interview with the co-chair, Edgar Magana of Salesforce. This SIG will address several goals and challenges, including reference architecture. Edgar explains these through the lens of Salesforce's Spinnaker implementation, which targets both Kubernetes and EC2 deployments.  

## [Adopting the V2 K8S Provider As V1 Support Sunsets](https://blog.spinnaker.io/farewell-to-the-kubernetes-v1-provider-79d93861c6e4)
Spinnaker 1.21, expected near the end of June, will be the final release that includes the Kubernetes V1 provider, as community best practices optimize for V2. Read more about generating V2-compliant, version-controlled Kubernetes manifests, and additional steps to migrate pipelines.

## [PaCRD Deep Dive: Try Out Spinnaker Pipelines as CRDs](https://www.youtube.com/watch?v=HZtRCyGA7yM)
Armory released a new "PaCRD" experience for experimental use this month. Watch to learn how to add a controller to your Spinnaker installation to manage application and pipeline objects as CRDs within your Kubernetes cluster. Store your pipeline definitions in the same format as other application resources, and provide your feedback.

## [Spinnaker Summit CFP Now Open](https://linuxfoundation.smapply.io/prog/spinnaker_summit_2020/)
With Spring upon us, the annual Spinnaker Summit is closer than you think. The CFP recently opened, and the application contains plenty of inspiration. Newly created tracks - Deep Dive, Hands-On, and Solutions & Case Studies - aim to create a high-quality program that will appeal to any CD stakeholder. Visit the #spinnaker-summit-2020 channel for brainstorming support, and count on help with presentation prep as needed. Submit your proposals today!

## [Fix Applied for Clouddriver SQL Injection Bug Discovered by Autodesk](https://github.com/spinnaker/clouddriver/pull/4435)
Engineers from Netflix and Armory acted quickly to include an important Clouddriver fix in the 1.17 release. The PEN testing team at Autodesk, a company using Spinnaker in production, discovered the SQL injection vulnerability and facilitated the quick fix. Community teamwork win!


## User Stories
## [Kubernetes-Native Spinnaker Pipelines with Istio at Descartes Labs](https://cd.foundation/blog/2020/02/24/descartes-labs-implementation-of-spinnaker-pipelines-the-end-of-waterfall/)
Watch Louis Vernon's story of how Descartes Labs, a cool AI-based geospatial analysis platform, evolved its waterfall deployments into modern Kubernetes pipelines, using GKE with Spinnaker, Istio and StackDriver.  Today, Istio routes updates between environments all running in the same cluster to deliver a stable SDLC.

## [Multi-environment Microservice Delivery With Spinnaker at JPMC](https://www.infoq.com/presentations/spinnaker-jpmorgan-chase/)
Hear Richard Francois, a VP at JP Morgan Chase, and Olga Kundzich explain how Spinnaker has helped the bank deploy software experiences to both public clouds and on-prem private clouds from one central locus of control and visibility. Monitoring system integration and no-code, zero-downtime deployments to Kubernetes, AWS, and the private cloud code-named "Gaia" have set this financial giant apart.

## [Adobe Experience Platform Leverages Spinnaker](https://www.facebook.com/costi.muraru/posts/3088480564511758)
Adobe SREs Constantin Muraru and Dan Popescu presented the aptly named "Deploying your real-time apps on thousands of servers and still being able to breathe" at StrataData in London. They sought an open source platform to pick up where Jenkins leaves off for more automated and reliable delivery. They chose Spinnaker based on its rich out-of-the-box integrations and deployment strategies. [Read more](https://medium.com/adobetech/experiences-with-spinnaker-on-adobe-experience-platform-bae6cf351f34).

## Tweet Street
Noteworthy tweets this month
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">It&#39;s now more reliable and highly scalable, providing customers data real time publishing.<br>Tech env: <a href="https://twitter.com/hashtag/Java13?src=hash&amp;ref_src=twsrc%5Etfw">#Java13</a> / <a href="https://twitter.com/hashtag/SpringBoot?src=hash&amp;ref_src=twsrc%5Etfw">#SpringBoot</a> hosted in GKE, PubSub, Storage and Redis. <a href="https://twitter.com/hashtag/Spinnaker?src=hash&amp;ref_src=twsrc%5Etfw">#Spinnaker</a> for deployment. It was the first time I used <a href="https://twitter.com/hashtag/GoogleCloudPlatform?src=hash&amp;ref_src=twsrc%5Etfw">#GoogleCloudPlatform</a> and I really love it. [2/2]</p>&mdash; Alan Menant (@AlanMenant) <a href="https://twitter.com/AlanMenant/status/1235982327085400067?ref_src=twsrc%5Etfw">March 6, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
***

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">- a pipeline that runs every 1min<br>- it runs a job that submits a task to the Spinnaker API<br>- this task looks up an app&#39;s metadata and sends an echo notification to page the app owner in PagerDuty<br>- we monitor these and get an alert if the number of pages is too low over 10min</p>&mdash; supermassive backlog (@FakeRyanGosling) <a href="https://twitter.com/FakeRyanGosling/status/1241476186670153728?ref_src=twsrc%5Etfw">March 21, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
***

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Writing down my experience deploying a digital ocean k8s cluster and installing spinnaker on it... No idea if this will turn into anything useful but hey, ima do it anyways.</p>&mdash; 🏳️‍⚧️ Kwyn ✨ (@kwyntastic) <a href="https://twitter.com/kwyntastic/status/1232805913917976576?ref_src=twsrc%5Etfw">February 26, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## Release Alerts
Information about the latest Spinnaker releases:
- [Release Notes: 1.19](https://gist.github.com/spinnaker-release/dbc44ac411d5076002b5db7c64b8c63e) and [What's New](https://blog.opsmx.com/spinnaker-1-19-whats-new/) summary from OpsMX
- [Release Notes: 1.18](https://gist.github.com/spinnaker-release/306d7e241272980642e918f64ed91fe3) and [What's New](https://blog.opsmx.com/spinnaker-1-18-whats-new/) summary from OpsMX

- [Release Notes: 1.17](https://gist.github.com/spinnaker-release/d020714e9190763f27e35701e14c6bc1)
