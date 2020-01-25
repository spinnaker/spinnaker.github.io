---
layout: single
title:  "Overview"
sidebar:
  nav: guides
---

{% include toc %}

> Managed Delivery is currently in Alpha and is not recommended for managing 
> mission-critical production services. Only EC2 and Titus cloud providers are currently supported and
> many features are still in flux or pending. 

## What is Managed Delivery? 

Managed Delivery is an initiative with two key goals.

-  Provide native means for Spinnaker Users to declaratively manage software delivery. 

    - With a *declarative* model, users describe the desired end-state of a deployed application. Spinnaker continually 
    calculates how this desired state maps to cloud resources. When desired state diverges from actual cloud state, 
    Spinnaker figures out how to safely bring the deployed state in-line with the desired. 

    - This is in stark contrast to the *imperative* pipeline model, which requires users to define every step of
    their delivery flow. Pipelines remain a powerful first class feature of Spinnaker that will offer greater
    flexibility than Managed Delivery for the foreseeable future. However, we feel the declarative approach is
    preferable for most delivery flows. Good pipeline design requires a depth of Spinnaker and cloud knowledge,
    while system failures impacting pipeline execution may leave environments in a transitional state without
    an automatic path back to normalcy. A declarative model solves both issues.

- Provide Spinnaker Operators with powerful new means to raise the level of operational abstraction offered to
    their users.

    - By informing how declarative models are resolved, operators can centrally maintain delivery best practices
    and automate change propagation without knowledge of how product teams have customized delivery pipelines. 
    - Examples range from offloading decision making about the regions a service should deploy into, to providing 
    means to rapidly redeploy thousands of services running in hundreds of AWS accounts in order to address an OS 
    level security vulnerability.

## Contributing

If you are interested in contributing, the Managed Delivery initiative is under the auspices of the 
[Spinnaker-as-Code SIG](https://github.com/spinnaker/governance/blob/master/sig-spinnaker-as-code/README.md)
