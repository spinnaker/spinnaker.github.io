---
layout: single
title:  "Back Up Your Config"
sidebar:
  nav: setup
---

Once you are happy with your configured Spinnaker, you probably want an easy
way to reproduce/redeploy it that doesn't couple you to the VM that Halyard is
installed on. 

Most of Halyard's state is stored in the `~/.hal` directory for every deployment
of Spinnaker that it's managing. However, things like credential files or paths
to user data may appear in different folders on your file system. This makes
backing up the state of Spinnaker via Halyard tricky to do by hand... luckily,
Halyard has a solution.

At any point in time, you can run

```bash
hal backup create
```

This will produce a tar file that contains all linked local files, and a
modified halconfig file that points to the local files within the tarball.

> :warning: This includes all secrets you've supplied to hal. Keep this safe!

Given that tar file, you can at any time for any machine/user running Halyard
run

```bash
hal backup restore --backup-path <backup-name>.tar
```

and Halyard will expand & replace the existing `~/.hal` directory with the
backup. 

> :warning: Keep in mind that if you run `hal backup create` and `hal backup
> restore` in succession on the same machine, links to local files will be
> rewritten to point to those in a `~/.hal/.backup/required-files` directory.

## Next steps

After this step is done, you can use Spinnaker to create pipelines and deploy software, 
but there are some [further configuration steps](/setup/other_config/) you're likely to need.
