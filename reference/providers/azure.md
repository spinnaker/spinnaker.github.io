---
layout: single
title:  "Azure"
sidebar:
  nav: reference
---

{% include toc %}

If you are not familiar with Azure or any of the terms used below, please consult the Azure [reference documentation](https://docs.microsoft.com/en-us/azure/).

## Resource Mapping

### Account
In [Azure](https://azure.microsoft.com/) (AZ), an [Account](/concepts/providers/#accounts)
maps to a credential able to authenticate against a given [Azure](https://azure.microsoft.com/) (AZ)
project - see the [setup guide](/setup/providers/azure).

### Load Balancer
A Spinnaker **load balancer** maps to an Azure [Application Gateway](https://azure.microsoft.com/services/application-gateway/).

### Server Group
A Spinnaker **server group** maps to an Azure
[Virtual Machine Scale Set](https://azure.microsoft.com/services/virtual-machine-scale-sets/).

### Instance
A Spinnaker **instance** maps to an Azure [Virtual Machine Instance](https://azure.microsoft.com/services/virtual-machines/).

Instances in a Virtual Machine Scale set all use the same standard/custom VHD.  

[Linux VM sizes](https://docs.microsoft.com/azure/virtual-machines/linux/sizes)
[WIndows VM sizes](https://docs.microsoft.com/azure/virtual-machines/windows/sizes)

### Security Group
A Spinnaker **security group** maps to an Azure [Network Security Group](https://docs.microsoft.com/azure/virtual-network/virtual-networks-nsg).

## Operation Mapping

### Deploy
Deploys a new Azure Virtual Machine Scale set.

### Clone
Clones an Azure Virtual Machine Scale Set into a new Virtual Machine Scale set.

### Destroy
Destroys an Azure Virtual Machine Scale set.

### Resize
Not supported

### Enable
Enables an Azure Virtual Machine Scale Set to receive traffic.

### Disable
Disables an Azure Virtual Machine Scale set from receiving traffic.

### Create Load Balancer
Creates a new Application Gateway in Azure.

### Edit Load Balancer
Edits the properties of an Application Gateway.

### Delete Load Balancer
Deletes an Application Gateway.  Delete will fail if the App Gatway is connected to a Virtual Machine Scale Set.

### Create Security Group
Creates a Network Security Group in the specified Virtual Network.

### Clone Security Group
Clones a Network Security Group in the same virtual Network.

### Edit Inbound Rules
Edit the inbound traffic rules on the corresponding Network Security Group.

### Delete Security Group
Deletes the Network Security Group.
