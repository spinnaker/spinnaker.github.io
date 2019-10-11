---
layout: single
title:  "Authentication & Authorization"
sidebar:
  nav: reference
---

{% include toc %}

## Authentication & Authorization
This is a high-level explanation of how authentication and authorization work within Spinnaker itself.  


- Redis stores computed roles, default permissions, and roles from external systems
- Clouddriver gets known accounts
- Front50 gets known apps

[Details on authentication](./authentication/)

[Details on authorization](./authorization/)



## Setup & Configuration

For more information on actual use of this see [Setup Authentication & Authorization](/setup/security/)
