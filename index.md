---
layout: home
conference_ad_row:
  title: Spinnaker Summit 2019
  excerpt: "We're hosting a [conference](https://www.spinnakersummit.com) in San Diego, CA on November 15-17th. If you're interested in using Spinnaker, a current Spinnaker user, a Spinnaker operator, or in the DevOps space this conference will be interesting to you! \n \n We'd like to also extend a big \"Thank You!\" to the many many folks who submitted talks for this year. The review committee has started the process of reading through all of the proposals and will be publishing an official summit agenda soon."
  image_path: assets/images/summit-socialmedia-transparent.png
  alt: "Spinnaker Summit Logo"
spinnaker_row:
  title: Spinnaker is an open source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence.
  excerpt: "Created at Netflix, it has been battle-tested in production by hundreds of teams over millions of deployments. It combines a powerful and flexible pipeline management system with integrations to the major cloud providers."
  image_path: assets/images/spinnaker-logo-inline.svg
  alt: "Spinnaker Logo"
multi_cloud_row:
  title: Multi-Cloud
  excerpt: "Deploy across multiple cloud providers including AWS EC2, Kubernetes, Google Compute Engine, Google Kubernetes Engine, Google App Engine, Microsoft Azure, Openstack, Cloud Foundry, and Oracle Cloud Infrastructure, with DC/OS coming soon."
  image_path: assets/images/cloud.svg
  alt: "Multi-Cloud Logo"
automated_releases_row:
  title: Automated Releases
  excerpt: "Create deployment pipelines that run integration and system tests, spin up and down server groups, and monitor your rollouts. Trigger pipelines via git events, Jenkins, Travis CI, Docker, CRON, or other Spinnaker pipelines."
  image_path: assets/images/automated-releases.svg
  alt: "Automated Releases Logo"
best_practices_row:
  title: Built-in Deployment Best Practices
  excerpt: "Create and deploy immutable images for faster rollouts, easier rollbacks, and the elimination of hard to debug configuration drift issues. Leverage an immutable infrastructure in the cloud with built-in deployment strategies such as red/black and canary deployments."
  image_path: assets/images/best-practices.svg    
  image_class: best_practices_img
  alt: "Best Practices Logo"
aws_provider:
  image_path: assets/images/aws.png
  alt: "AWS Logo"
  image_class: spin_cloud_provider__aws
gcp_provider:
  image_path: assets/images/gcp.png
  alt: "GCP Logo"
  image_class: spin_cloud_provider__gcp
k8s_provider:
  image_path: assets/images/k8s.png
  alt: "Kubernetes Logo"
  image_class: spin_cloud_provider__k8s
azure_provider:
  image_path: assets/images/azure.png
  alt: "Azure Logo"
  image_class: spin_cloud_provider__azure
appengine_provider:
  image_path: assets/images/appengine.svg
  alt: "App Engine Logo"
  image_class: spin_cloud_provider__appengine
cf_provider:
  image_path: assets/images/cf.png
  alt: "Cloud Foundry Logo"
  image_class: spin_cloud_provider__cf
oracle_provider:
  image_path: assets/images/oracle.svg
  alt: "Oracle Cloud Infrastructure Logo"
  image_class: spin_cloud_provider__oracle
active_community_row:
  title: Active Community
  excerpt: "Join a community that includes Netflix, Google, Microsoft, Veritas, Target, Kenzan, Schibsted, and many others, actively working to maintain and improve Spinnaker."
  image_path: assets/images/community.svg
ci_integrations_feature:
  title: CI Integrations
  content: "Listen to events, collect artifacts, and trigger pipelines from Jenkins or Travis CI. Triggers via git, cron, or a new image in a docker registry are also supported."
monitoring_integrations_feature:
  title: Monitoring Integrations
  content: "Tie your releases to monitoring services Datadog, Prometheus, Stackdriver, SignalFx, or New Relic using their metrics for canary analysis."
cli_feature:
  title: CLI for Setup and Admin
  content: "Install, configure, and update your Spinnaker instance with halyard, Spinnaker’s CLI tool."
deployment_strategies_feature:
  title: Deployment Strategies
  content: "Configure pipelines with built-in deployment strategies such as highlander and red/black,  with rolling red/black and canary in active development, or define your own custom strategy."
vm_bakery_feature:
  title: VM Bakery
  content: "Bake immutable VM images via Packer, which comes packaged with Spinnaker and offers support for Chef and Puppet templates."
notifications_feature:
  title: Notifications
  content: "Set up event notifications for email, Slack, HipChat, or SMS (via Twilio)."
access_control_feature:
  title: Role-based Access Control
  content: "Restrict access to projects or accounts by hooking into your internal authentication system using OAuth, SAML, LDAP, X.509 certs, Google groups, Azure groups, or GitHub teams."
manual_judgments_feature:
  title: Manual Judgments
  content: "Require a manual approval prior to releasing an update with a manual judgement stage."
execution_windows_feature:
  title: White-listed Execution Windows
  content: "Restrict the execution of stages to certain windows of time, making sure deployments happen during off-peak traffic or when the right people are on hand to monitor the roll-out."
chaos_monkey_feature:
  title: Chaos Monkey Integration
  content: "Test that your application can survive instance failures by terminating them on purpose."
netflix_case_study:
  title: Global Continuous Delivery with Spinnaker
  image_path: assets/images/netflix_logo.jpg
  image_class: spin_case_study__netflix
  alt: "Netflix Logo"
  links:
    - label: READ MORE
      src: "https://medium.com/netflix-techblog/global-continuous-delivery-with-spinnaker-2a6896c23ba7"
waze_case_study:
  title: Multi-cloud continuous delivery using Spinnaker at Waze
  image_path: assets/images/waze_logo.jpg
  image_class: spin_case_study__waze
  alt: "Waze Logo"
  links:
    - label: READ MORE
      src: "https://cloudplatform.googleblog.com/2017/02/guest-post-multi-cloud-continuous-delivery-using-Spinnaker-at-Waze.html"
    - label: WATCH THE PRESENTATION
      src: "https://www.youtube.com/watch?v=05EZx3MBHSY"
#target_case_study:
#  title: How and Why We Moved To Spinnaker
#  image_path: assets/images/spinnaker-logo-og.png
#  alt: "Target Logo"
#  links:
#    - label: READ MORE
#      src: "https://www.youtube.com/watch?v=05EZx3MBHSY"
#intuit_case_study:
#  title: Small Business Group's Spinnaker Journey
#  image_path: assets/images/spinnaker-logo-og.png
#  alt: "Intuit Logo"
#  links:
#    - label: WATCH THE VIDEO
#      src: "https://vimeo.com/208263013/e0bd26b92f"
---

<div class="spin_header">
  <img class="spin_header__swoosh" src="{{ "assets/images/top-right-swoosh.svg" | absolute_url }}" alt="Spinnaker Swoosh"/>
  <div class="spin_header__inner_wrap">

    {% include masthead.html %}

    <div class="spin_header__text">
      <h1>Cloud Native Continuous Delivery</h1>
      <h2>Fast, safe, repeatable deployments for every Enterprise</h2>
    </div>
    <ul class="spin_call_to_action">
      <li><a href="/concepts/">HOW IT WORKS</a></li>
      <li><a href="/setup/">INSTALL SPINNAKER</a></li>
      <li><a href="/guides/user/get-started/">GET STARTED</a></li>
      <li><a href="/publications/ebook/">READ OUR EBOOK</a></li>
    </ul>
  </div>
</div>

<div class="spin_header__push_down">
{% include splash_feature_row id="conference_ad_row" type="summit" %}
{% include splash_feature_row id="spinnaker_row" type="right" %}
{% include splash_feature_row id="multi_cloud_row" type="left" %}
{% include splash_feature_row id="automated_releases_row" type="right" %}
{% include splash_feature_row id="best_practices_row" type="left" %}
{% include splash_feature_row id="active_community_row" type="right" %}
</div>
<div class="spin_cloud_providers">
  <img class="spin_cloud_providers__swoosh" src="{{ "assets/images/left-swoosh.svg" | absolute_url }}" alt="Spinnaker Swoosh"/>
  <div class="spin_cloud_providers__blue">
    <div class="spin_cloud_providers__wrapper">
      <h1 class="spin_cloud_providers__header">Supported Cloud Providers</h1>
      <div class="clearfix">
        {% include spinnaker_cloud_provider id="aws_provider" %}
        {% include spinnaker_cloud_provider id="gcp_provider" %}
        {% include spinnaker_cloud_provider id="k8s_provider" %}
        {% include spinnaker_cloud_provider id="oracle_provider" %}
      </div>
      <div class="clearfix">
        {% include spinnaker_cloud_provider id="azure_provider" %}
        {% include spinnaker_cloud_provider id="appengine_provider" %}
        {% include spinnaker_cloud_provider id="cf_provider" %}
      </div>
    </div>
  </div>  
</div>

<h1 class="spin__heading spin_cloud_providers__push_down">Features List</h1>
<div class="clearfix">
  {% include spinnaker_feature_box id="ci_integrations_feature" %}
  {% include spinnaker_feature_box id="monitoring_integrations_feature" %}
</div>
<div class="clearfix">
  {% include spinnaker_feature_box id="cli_feature" %}
  {% include spinnaker_feature_box id="deployment_strategies_feature" %}
</div>
<div class="clearfix">
  {% include spinnaker_feature_box id="vm_bakery_feature" %}
  {% include spinnaker_feature_box id="notifications_feature" %}
</div>
<div class="clearfix">
  {% include spinnaker_feature_box id="access_control_feature" %}
  {% include spinnaker_feature_box id="manual_judgments_feature" %}
</div>
<div class="clearfix">
  {% include spinnaker_feature_box id="execution_windows_feature" %}
  {% include spinnaker_feature_box id="chaos_monkey_feature" %}
</div>

<h1 class="spin__heading mt2">Case Studies</h1>

<div class="clearfix">
  {% include spinnaker_case_study id="netflix_case_study" %}
  {% include spinnaker_case_study id="waze_case_study" %}
</div>

<!-- <div class="clearfix">
  {% include spinnaker_case_study id="target_case_study" %}
  {% include spinnaker_case_study id="intuit_case_study" %}
</div> -->
