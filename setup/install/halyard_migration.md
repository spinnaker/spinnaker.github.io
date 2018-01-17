---
layout: single
title:  "Migrate Halyard from Debian to Jar installation"
sidebar:
  nav: setup
---

{% include toc %}

## Migration from debian to jar based installation

If you already have a debian (apt) based installation of halyard, you will
need to migrate to our new jar based installation to recieve future updates.

To migrate from a debian based installation to a jar based installation:

```bash
HALYARD_BACKUP_PATH=$(hal backup create -q)

sudo apt remove spinnaker-halyard/trusty-stable -y < /dev/null
sudo rm /etc/apt/sources.list.d/halyard.list && sudo rm /etc/apt/sources.list.d/halyard.list.save
sudo apt update

curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh

hal backup restore --backup-path=$HALYARD_BACKUP_PATH
```