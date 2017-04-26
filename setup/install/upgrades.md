---
layout: single
title:  "Upgrading"
sidebar:
  nav: setup
---

If you want to change Spinnaker versions using Halyard, you can read about
supported versions like so:

```bash
hal version list
```

And pick a new version like so:

```bash
hal config version edit --version $VERSION

# this will update Spinnaker
hal deploy apply 
```
