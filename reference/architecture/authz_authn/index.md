---
layout: single
title:  "Authentication & Authorization"
sidebar:
  nav: reference
---

{% include toc %}

## Authentication & Authorization
This is a high level of how authentication and authorization work with-in spinnaker itself.  


- Redis to store computed roles, default permissions, roles from external systems
- Clouddriver to get known accounts
- Front50 to get known apps

[Details on authentication](./authentication/)

[Details on authorization](./authorization/)



## Setup & Configuration

For more information on actual use of this see [Setup Authentication & Authorization](/setup/security/)
