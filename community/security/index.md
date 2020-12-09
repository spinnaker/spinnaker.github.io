---
layout: single
title:  "Security"
sidebar:
  nav: community
---

{% include toc %}

## Responsible Disclosure Policy

We know that security is very important to the Spinnaker community.  We welcome _(and encourage)_ any reviews and testing of Spinnaker's open source code to ensure the quality and security of Spinnaker for users around the world.

### Where should I report security issues?

If you would like to report a vulnerability in the Spinnaker open source code, please email us at [security@spinnaker.io](mailto:security@spinnaker.io) right away, and a member of the [Security Special Interest Group (SIG)](https://github.com/spinnaker/governance/tree/master/sig-security) will get back to you as soon as we are able.  We deeply appreciate your support in discovering and disclosing security issues in a responsible way.

### What should I include in a security report?

Please share any information we need to understand and reproduce the security issue you've discovered, including:

* A complete description of the security issue  
* Steps to detect or reproduce the security bug  
* Versions and configurations affected by the issue  
* Whether you would like credit for finding the bug

*Note:* As an independent open source community, we do not provide bug bounties for security reports at this time.

### What kind of bugs should I report?

To help us prioritize bugs affecting the Spinnaker community, please only report security issues affecting the Spinnaker open source code or common configurations for deployed Spinnaker services.  Please keep in mind that security issues with higher severity will receive priority over less impactful bugs.

*Note:* Do not conduct testing or security research against systems or data that you do not own.

### Can I include code for fixing a security issue?

Absolutely!  We love code contributions too, especially for security improvements.  Please follow the [contributing guidelines](https://spinnaker.io/community/contributing/submitting/) for any changes you would like to share.  If you have any questions, feel free to contact the Security SIG by saying _hello_ in the [Spinnaker Slack](http://join.spinnaker.io) [#security-sig](https://spinnakerteam.slack.com/archives/CFN8F5UR2) channel.

### How are security bugs handled?

We've created a 4-step process to review and mitigate any reported security issues in Spinnaker open source code.  These steps are further described in the [Vulnerability Handling Process](https://docs.google.com/document/d/1dCJ17v2K-lEVBTEGsgS4xnuOZo30Ufd3gSoYrG6XZfA) document.

#### Step 1: A Front Door

As part of the Spinnaker community, members of the Security SIG have volunteered to review and triage security vulnerabilities detected in Spinnaker open source code.  All security issues that have been responsibly disclosed to [security@spinnaker.io](mailto:security@spinnaker.io) will be acknowledged and reviewed within one week of receiving the report.

#### Step 2: Evaluating New Reports

New security vulnerabilities will be assessed against our predefined security taxonomy, which is explained in detail in our [Vulnerability Handling Process](https://docs.google.com/document/d/1dCJ17v2K-lEVBTEGsgS4xnuOZo30Ufd3gSoYrG6XZfA).  We will work with you _(the security researcher)_ to determine the scope and impact of the security issue, assign a severity rating, and reserve a [CVE ID](https://cve.mitre.org/cve/identifiers/) for newly discovered bugs.

#### Step 3: Tracking Vulnerabilities

We track and monitor security vulnerabilities in Spinnaker open source code through non-public mechanisms available to all members of the Security SIG and will review new security reports during the Security SIG bi-weekly meeting (or more frequently, as needed).

#### Step 4: Mitigating Vulnerabilities

Once a security issue has been confirmed and evaluated, the Security SIG will work with other members of the Spinnaker community to identify individuals to develop a patch or fix for each bug.  Code changes for security issues will be developed publicly unless otherwise accepted by majority vote of the Security SIG.  We will then track released security patches in the changelog for each release and update the CVE record.

## I have another question not answered here.  Who should I talk to?

For general questions about Spinnaker security, feel free to join us in the [Spinnaker Slack](http://join.spinnaker.io) [#security-sig](https://spinnakerteam.slack.com/archives/CFN8F5UR2) channel.  Questions or feedback regarding a security issue or vulnerability should be sent directly to [security@spinnaker.io](mailto:security@spinnaker.io).

## I'd like to participate in the [Security SIG](https://github.com/spinnaker/governance/tree/master/sig-security).  How do I join?

We're thrilled that you're interested in supporting Spinnaker security!  The Security SIG meets bi-weekly to address security issues and provide input on security capabilities within the Spinnaker project.  You can get startetd by [requesting an invite](http://join.spinnaker.io) to the Spinnaker Slack team and joining the [#security-sig](https://spinnakerteam.slack.com/archives/CFN8F5UR2) channel.
