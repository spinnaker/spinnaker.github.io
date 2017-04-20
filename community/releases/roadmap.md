---
title:  "Roadmap"
sidebar:
  nav: community
---

{% include toc %}

### 2017 Q1

| Area | Features |
|---|---|
| General | Establish regular versioned releases of Spinnaker |
| | [halyard](https://github.com/spinnaker/halyard) - configure & verify GCE, K8S/GKE providers |
| | [halyard](https://github.com/spinnaker/halyard) - configure & verify container registry providers |
| | [halyard](https://github.com/spinnaker/halyard) - deploy clustered-Spinnaker to Kubernetes |
| | [halyard](https://github.com/spinnaker/halyard) - install Spinnaker via `apt-get` |
| | Managed Pipeline Templates - Codifying delivery best practices can be achieved through centrally managed master pipeline definitions; teams can choose to implement and even extend base functionality so as to reduce configuration needs |
| | Rolling Red/Black deployment strategy |
| | Begin work on canary release strategy |
| Security | LDAP for authentication/identity store |
| | LDAP for authorizations group membership store |
| | Stretch: Azure AD Graph support for Authorization |
| GCE | Stackdriver dashboard for operating Spinnaker |
| Kubernetes | Spinnaker on Kubernetes Google Cloud Monitoring integration |
| | Stackdriver dashboard for operating Spinnaker |
| Azure | Spinnaker QuickStart in Azure Marketplace |
| | Azure Blob Support/Deprecate Cassandra support |
| | Increase test coverage/ documentation updates |
| | Support for multiple bake templates in packer |
| | Codelab – VM deployment on Azure w/ Spinnaker |
| | Codelab – Deploying to Kubernetes on Azure w/ Spinnaker |
| Cloud Foundry | Code lab for installing Spinnaker on CF and deploying to CF |
| App Engine | App Engine provider beta |



### 2016 Q4

| Area | Features |
|---|---|
| General | Beginning Declarative Continuous Delivery format and strategy |
| | Workflow engine refactoring for V2 API |
| Security | Authentication support with OAuth |
| | Authorizations support with Google Groups, GitHub teams and SAML groups |
| Google Compute Engine | [L4 Load Balancer SSL](https://cloud.google.com/compute/docs/load-balancing/tcp-ssl/) support |
| | [L7 HTTP/S Load Balancer support](https://cloud.google.com/compute/docs/load-balancing/http/) |
| | [Internal Load Balancer](https://cloud.google.com/compute/docs/load-balancing/internal/) support |
| | Consul integration for enable/disable operations |
| Kubernetes | [Deployment](http://kubernetes.io/docs/user-guide/deployments/) support |
| | Spinnaker on Kubernetes Google Cloud Logging integration |
| Openstack | Integration tests (citest) implementation |
| | Implementation documentation |
| | Consul support |
| Azure | Solution Template - Deploy to VM Scale Set using Jenkins and Spinnaker |
| | Key Vault Support |

