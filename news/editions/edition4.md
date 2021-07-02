---
layout: single
title:  "*Flying*  Edition 4"
sidebar:
  nav: news
redirect_from: /news/latest/
---
> It's been a while! This mega-issue will catch you up on new Spinnaker content from the past few months. Spinnaker sets the standard for open source innovation because YOU evolve it.

## [Join us for Spinnaker Summit and Summit Gardening Days](https://events.linuxfoundation.org/spinnaker-summit)
This year's Spinnaker Summit is a 4-week virtual event, October 19th - November 12. Learn from technical and leadership-focused talks on Tuesdays and Thursdays, and catch keynotes and special events on Wednesdays. Speakers hail from Adobe, Airbnb, Autodesk, AWS, Cisco, Cloudera, Modzy, Netflix, Pinterest, Red Hat, Salesforce, SAP, Snap, Splunk, Sumo Logic, Xero and more. Hack all month at [Gardening Days](https://github.com/spinnaker-hackathon/gardening), our global hackathon, part of Summit schedule this year with exciting challenges from GitHub, Sumo Logic, and more. [Get your Summit tickets now](https://events.linuxfoundation.org/spinnaker-summit/register/)!

## Solution guides

### [How to build a CI/CD pipeline with Spinnaker](https://youtu.be/nTXrKiQEeO8)
In this episode of Season of Scale, Carter Morgan shows you how you can utilize Google's Cloud Build and Artifact Registry with Spinnaker and other tools to develop an automated, tag-based continuous integration and deployment pipeline.

### [Using CodeBuild in Spinnaker for continuous integration](https://aws.amazon.com/blogs/devops/using-codebuild-in-spinnaker-for-continuous-integration/)
Learn how to use AWS CodeBuild in Spinnaker to provide fully managed continuous integration capabilities as a stage in a Spinnaker pipeline. Follow this guide to enable and connect to the AWS provider, then access and configure pipeline triggers for your CodeBuild projects. The CodeBuild stage is available in Spinnaker 1.19 and higher.

### [Continuous deployment to Kubernetes using GitHub-triggered Spinnaker pipelines](https://blog.opsmx.com/continuous-deployment-to-kubernetes-using-github-triggered-spinnaker-pipelines/)
Learn to configure a webhook to trigger pipelines in Spinnaker 1.19.1 based on commits to a GitHub repository. Set up Spinnaker to listen to changes in a GitHub artifact repository, inject changed GitHub files as artifacts into your pipeline, and verify execution.

### [Spinnaker – Configuring dynamic Kubernetes accounts using Vault](https://blog.opsmx.com/spinnaker-configuring-dynamic-kubernetes-accounts-using-vault/)
We can configure Spinnaker's Clouddriver with external configuration stores, such as HashiCorp Vault to keep Kubernetes account information secure outside of Spinnaker. Consult this guide and its [sequel](https://blog.opsmx.com/spinnaker-externalising-kubeconfig-files-of-kubernetes-accounts/) to learn how to externalize dynamic Kubernetes accounts and kubeconfig files in Vault.

### [Spinnaker idea: reusable run job stages via script runner containers](https://medium.com/@tomas_lin/spinnaker-idea-reusable-run-job-stages-via-script-runner-containers-ff5fd95ec056)
Combine the deployment ease of the run script stage with the security advantages of a containerized stage by building general runner containers that run mix-and-match script workflows from S3. Enjoy the flexibility and security of a container runtime, and reduce time spent building containers.

### [Deploying a service mesh application to Kubernetes using Spinnaker](https://medium.com/@timawang/deploying-a-service-mesh-application-to-kubernetes-using-spinnaker-c509cda906ed)
Set up a complete CI/CD pipeline from scratch using native cloud services, Spinnaker, and popular tools such as Kubernetes, Istio, Calico, and Google Cloud Build. This guide gets you started quickly with a devops pipeline that you can further tweak according to your use case.

### [Continuous delivery pipeline for Kubernetes using Spinnaker](https://dzone.com/articles/continuous-delivery-pipeline-for-kubernetes-using)
This post provides a how-to guide on pushing new releases of an application to a Kubernetes cluster using Jenkins, Docker Hub, and Spinnaker. It demonstrates enabling automatic deployments to a staging environment, and supervised deployments to production.

### [Learn how to integrate Jenkins with Spinnaker](https://www.youtube.com/watch?v=s6NaYmD3cJk)
Follow the OpsMx Spinnaker tutorial and begin learning how to integrate Jenkins with Spinnaker to do continuous integration within your software delivery pipelines.

### [Securing your AWS deployments with Spinnaker and Armory Enterprise](https://youtu.be/zME-qXOo55k)
In this webinar, Paul Roberts of AWS and Lee Faus of Armory discuss the struggle between velocity and governance. How can we experiment while still enforcing deployment policies? You'll learn about  reusable modules that reduce the number of stages needed for deployment, and lockable pipelines that enforce best practices.

### [Integrating Spinnaker with ServiceNow](https://www.armory.io/blog/integrating-spinnaker-with-servicenow/)
Using ServiceNow as a system of record for software code and infrastructure changes to production  environments? In this video and blog, learn to trigger Spinnaker pipelines from ServiceNow, use Spinnaker Pipeline Expressions to capture build metadata, and automate ServiceNow change requests.

## Success stories

### [True continuous deployment: From dream to reality with Spinnaker at Upside](https://engineering.upside.com/true-continuous-deployment-from-dream-to-reality-with-spinnaker-5b48487d2f88)
Learn how and why Upside is leveraging Spinnaker to give its teams more runway to build out complex and robust deployment pipelines with ease. With Continuous Deployment, Upside engineers can further increase the velocity of deployments, as well as their confidence in them.

### [Spinnaker @ GIPHY](https://engineering.giphy.com/spinnaker-giphy/?fbclid=IwAR1aztJT68aqrDUBzPDGmYfpTQfvpNK5WHkVBQ1lxLViGbg6yx8aoJj-hMI)
Understand the Site Reliability team at GIPHY's process for distributing applications to Kubernetes on AWS servers. Spinnaker has made it easy for GIPHY to integrate with existing Jenkins pipelines and tooling, deploy to multiple cluster via Helm, and handle automated canary testing and releases.

### [Our journey to continuous delivery at Grab (part 1)](https://engineering.grab.com/our-journey-to-continuous-delivery-at-grab)
Read an in-depth account of 2 years spent improving the continuous delivery processes for backend services at Grab. Part One describes Grab's starting point, and the software and tools created and integrated. Grab chose Spinnaker because of its maturity, support of complex workflows and multicloud, open-source extensibility, and lack of a single point of failure.

### [Zero to 1000+ applications large scale CD adoption at Cisco with Spinnaker and OpenShift](https://youtu.be/RpIHjGg_fcs)
In this webinar, Balaji Siva, VP of Products at OpsMx, engages Anil Anaberumutt, IT architect at Cisco, and Red Hat Sr. Solutions Architect, Vikas Grover, in a discussion about Cisco’s CD challenges. They discuss lessons learned, best practices implemented, and key results achieved on their CD transformation journey.

## New & newsworthy

### [Telltale: Netflix application monitoring simplified](https://netflixtechblog.com/telltale-netflix-application-monitoring-simplified-5c08bfa780ba)
Read about Telltale, the intelligent monitoring tool that Netflix uses with Spinnaker to monitor over 100 applications in production. As Spinnaker deploys them, Telltale continuously monitors the health of instances running new builds for faster detection and resolution times.

### [Serializing your culture with Kelsey Hightower](https://youtu.be/rNpB9Mn0dm0)
Kelsey Hightower discusses culture and collaboration in the software development and delivery life cycle. How can we leverage a platform like Spinnaker to treat security and compliance as part of the whole SDLC? Hear Kelsey talk about his experience with continuous delivery tools versus platforms, and understand why he focuses so much on culture in his work with Kubernetes and cloud adoption.

### [Spinnaker projects participating in Google Summer of Code](https://cd.foundation/blog/2020/05/18/9-cd-foundation-projects-are-participating-in-this-years-google-summer-of-code/)
This year, we joined GSoC to bring more student developers into the Spinnaker community. We nurtured two Spinnaker projects: "Drone CI type for Spinnaker pipeline stage" from Victor Odusanya (mentored by Armory engineer Cameron Motevasselani) and “Continuous Delivery, Continuous Deployments with Spinnaker” from Moki Daniel (mentored by Armory engineer Fernando Freire).

### [The Continuous Delivery Foundation, interoperability, and open standards](https://www.infoq.com/podcasts/continuous-delivery-foundation/)
Tracy Miranda, the new Governing Board chair of the CDF, discusses the foundation's purpose and interoperability goals on the InfoQ podcast. Read more about Tracy's vision of standardized metadata in continuous delivery pipelines and how Spinnaker's advanced deployment strategies fit in.

### [Deep Dive into Spinnaker and the Spinnaker Operator](https://youtu.be/-p_CJc9BjAM)
The Spinnaker Operator makes deploying and managing the full lifecycle of Spinnaker app simple and reliable, leveraging a Kubernetes-native GitOps workflow and tools like kubectl, helm, and kustomize. This OpenShift Commons briefing explains and [demonstrates](https://youtu.be/5IMkZnF09d8) the [operator](https://github.com/armory/spinnaker-operator) and tours Armory Enterprise features.

## New products & partnerships

#### [Deploy EC2 Spot instances using new Spinnaker integration with Spot's Elastigroup](https://spot.io/news/2020-09-21/streamline-your-devops-workflow-with-spinnaker-and-spot/)

#### [OpsMx offers Open Enterprise Spinnaker on Red Hat Marketplace](https://aithority.com/it-and-devops/cloud/opsmx-announces-availability-of-open-enterprise-spinnaker-on-red-hat-marketplace/)

#### [Armory joins the AWS Partner Network Global Startup Program](https://www.newsanyway.com/2020/06/11/armory-joins-the-aws-partner-network-global-startup-program/)

#### [New Relic & Grafana partner to advance open instrumentation, improving open standards for Spinnaker observability](https://www.businesswire.com/news/home/20200810005231/en/New-Relic-and-Grafana-Labs-Partner-to-Advance-Open-Instrumentation)


## Release Alerts
Information about the latest Spinnaker releases:
- [Release Notes: 1.21](https://spinnaker.io/community/releases/versions/1-22-1-changelog#spinnaker-release-1-22-0)
- [Release Notes: 1.22](https://spinnaker.io/community/releases/versions/1-21-4-changelog#spinnaker-release-1-21-0)
- [Release Notes: 1.20](https://spinnaker.io/community/releases/versions/1-20-8-changelog#spinnaker-release-1-20)

_To be notified when new Spinnaker versioned releases are available, please join the [spinnaker-announce](https://groups.google.com/forum/#!forum/spinnaker-announce) Google Group (requires a Google account)._

## Jobs

<add some jobs here>

Trying to hire a Spinnaker engineer? [Join Spinnaker Slack](https://join.spinnaker.io) and add the jobs you'd like to advertise to the [#Spinnaker-News Channel](https://spinnakerteam.slack.com/archives/C011W1CNW8Y)


## Tweet Street
Noteworthy tweets:

<add some tweets here>
