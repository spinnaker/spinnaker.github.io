---
layout: single
title: "Getting Set Up for Spinnaker Development"
sidebar:
  nav: guides
---

{% include toc %}

This page describes the steps a Developer should take to fetch Spinnaker's codebase
and get set up to work on it.

Follow the [contributing guidelines](/community/contributing/submitting/)
if you plan to submit your work as a patch to the open source project.

# System Requirements

This guide assumes you have access to a machine with a minimum specification of:

- 18 GB of RAM
- A 4 core CPU
- Ubuntu 14.04, 16.04 or 18.04

> This guide has been tested against a machine with these specifications but it's feasible
> to develop Spinnaker on different flavors of Linux and with fewer resources, depending on
> what you're working on.

# Installing Spinnaker's codebase with Halyard

The following steps will install Spinnaker's management tool, Halyard, fetch Spinnaker's
codebase, and perform just enough configuration to get Spinnaker up and running.

Each of these steps will take between 5 and 30 minutes to finish and may require you to
do multiple things, such as installing CLI tools or configuring service accounts. A good
way to approach this process is to open a step in its own browser tab and then work through
it to completion, closing it (and any others you've opened in support of it) once it's done.

1. [Install Halyard](/setup/install/halyard/#install-on-debianubuntu-and-macos)
1. [Set up a storage service](/setup/install/storage/)
1. [Set up your cloud provider of choice](/setup/install/providers)
1. [Configure a LocalGit deployment](/setup/install/environment/#local-git)
1. Run `hal deploy apply`

## What does this do?

Halyard creates a directory at `~/dev/spinnaker` with the following contents:
- a subdirectory for each Spinnaker service containing that service's source code
- a `scripts` directory
- a `logs` directory
- a set of `.pid` files, one for each service that is running

The `scripts` directory contains scripts to start and stop each individual service. For
example calling `~/dev/spinnaker/scripts/deck-stop.sh` will kill the Deck process and
delete the `deck.pid` file. Running `~/dev/spinnaker/scripts/deck-start.sh` will restart Deck
and recreate its `deck.pid` file.

The final step, `hal deploy apply`, checks out the git repos for each service and launches
Spinnaker. You can then access the Deck UI by visiting `http://localhost:9000`.

> Halyard will figure out how to individually configure each of Spinnaker's services based on
> the settings you give it. You can change Halyard settings with the `hal` command but it's
> also worth knowing that Halyard configuration lives in the `~/.hal` directory and that the
> configuration it generates for each service is placed in the `~/.spinnaker` directory. This
> guide won't go into further detail on this but you can
> [read more about Halyard configuration here](/reference/halyard/).

# Making Changes to Spinnaker

Once you have a working LocalGit deployment you can begin to make changes to the codebase.
After you've made edits in the code of a service you can see those changes reflected
by restarting the service you've modified.

To restart a service call `hal deploy apply --service-names clouddriver`, replacing `clouddriver`
with whichever service you want to restart. The only service that does not require this kind
of restart is Deck; its webserver watches for file changes and re-compiles the application as
necessary.

# Configuring an IDE

## IntelliJ

Import the project into IntelliJ: 
1. Select `New` > `Project from Existing Sources`
1. Navigating to a service's `build.gradle` file (i.e., `~/dev/spinnaker/clouddriver/build.gradle`)

### Repairing a Broken Project

If your IntelliJ project becomes broken for any reason then a quick fix is to
clean your workspace and delete all files that git doesn't already know about:

1. Run `git clean -dnxf -e '*.iml' -e '*.ipr' -e '*.iws'` to perform a dry-run.  
   Make sure that you're happy with the output of this command before proceeding.
1. Run `git clean -dxf -e '*.iml' -e '*.ipr' -e '*.iws'` to perform the deletion.

# Debugging

Each Java service can be configured to listen for a debugger. To start the JVM in debug
mode, set the Java system property `DEBUG=true`.

The JVM will then listen for a debugger to be attached on a port specific to that service. The
service-specific debug ports are as follows:

| Service     | Port |
| :---------- | :----|
| Gate        | 8184 |
| Orca        | 8183 |
| Clouddriver | 7102 |
| Front50     | 8180 |
| Rosco       | 8187 |
| Igor        | 8188 |
| Echo        | 8189 |

The JVM will not wait for the debugger to be attached before starting a service; the relevant
JVM arguments can be seen and modified as needed in the service's `build.gradle` file.

# Next Steps

* If you haven't done so already, read through the
[Spinnaker Architecture reference](/reference/architecture/) to learn more about the individual
services' responsibilities and their dependencies on one-another. The
[list of ports each Spinnaker service uses](https://www.spinnaker.io/reference/architecture/#port-mappings)
can be very useful when querying and debugging a service's API.
* Consider working on one of the
[issues marked "beginner-friendly"](https://github.com/spinnaker/spinnaker/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22)
to start learning and contributing to Spinnaker right away.
* [Sign up for Spinnaker's Slack community](https://join.spinnaker.io) and join the
[#dev](https://spinnakerteam.slack.com/messages/C0DPVDMQE/) channel to ask questions and get feedback
while developing Spinnaker.
