---
layout: single
title:  "Scale Spinnaker"
sidebar:
  nav: setup
---

Spinnaker is a large system, made of many microservices, each intended to be
scaled, restarted, and configured independently. This provides operators a
great degree of flexibility, and allows Spinnaker to handle massive scale (1K+
deployments/day, 10K+ managed machines). However, there is no one-size-fits-all
approach for configuring Spinnaker; your organization's usage patterns will
need to inform how to scale your Spinnaker deployment.

These pages are intended to provide both an intuition for how Spinnaker works,
as well as concrete tips and advice to make Spinnaker more reliable at scale.
