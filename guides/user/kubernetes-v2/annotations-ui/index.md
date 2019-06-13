---
layout: single
title:  "Annotation-Driven UI"
sidebar:
  nav: guides
---

{% include toc %}

This guide describes how to surface information about your Kubernetes resources
in Deck's details panel using Kubernetes annotations.  These annotations can be
text or HTML and can include templated values that are populated when the annotation
is rendered by the browser.

## Example Usage

Here's a quick example of usage that will add a "Pod Info" section to the details
panel for a pod:

```bash
kubectl annotate pod my-prod-pod-v000 \
  pod-info.details.html.spinnaker.io="<a href='https://internal-elk.net/{{"{{ name "}}}}'>Internal Logs Service</a>"
```

Here's how this annotation will render in Spinnaker's UI:

{%
  include
  figure
  image_path="./pod_info_example.png"
%}

Dissecting the annotation, here's how the UI is constructed:

1. The section title, "Pod Info" comes from the annotation key:
**pod-info**.details.html.spinnaker.io. Notice that hyphens are replaced
with spaces and the section title is rendered using Title Case.
2. The entry is to be rendered as HTML.  This also comes from the annotation's key:
pod-info.details.**html**.spinnaker.io.  Excluding "html" here would have rendered
the link as plain text.
3. The HTML content is taken from the annotation's value:
`<a href='https://internal-elk.net/{{"{{ name "}}}}'>Internal Logs Service</a>`
4. The pod's name will be interpolated into the link. Notice the `{{"{{ name "}}}}` template
value in the href attribute.  The full set of available values are listed at the end
of this document.

## Rendering Text Annotations

To render the annotation as plain text, use an annotation key following this pattern:

```
(section-title).details.spinnaker.io/(key-name)
```

The `key-name` portion can be included or omitted.  If included the text will be rendered
as a key/value pair with `key-name` in bold and hyphens replaced with spaces.

## Rendering HTML

To render the annotation as HTML, use an annotation key following this pattern:

```
(section-title).details.html.spinnaker.io/(key-name)
```

`key-name` will not be rendered but is available to allow multiple HTML entries under
a single section title.

### Using Templates

Template values can be included in the content of the annotation and will be replaced when
they are rendered by Deck.  A templated value has the following appearance in an annotation:
`{{"{{ templateKey }}"}}` where `templateKey` will vary depending on the available set of keys
for the resource that is annotated.  The complete set of available keys is documented below.

#### Instances

- account - the spinnaker account for this resource
- apiVersion - the kubernetes apiVersion of this resource
- cloudProvider - this will always be `kubernetes`
- displayName - the name of the resource prepared for UI display
- hasHealthStatus - a boolean indicating whether the instance has health status
- healthState - the instance's health status, if available
- id - the instance's id
- kind - the kubernetes kind of this resource
- manifest - the kubernetes manifest as JSON object
- name - the resource's name
- namespace - the kubernetes namespace in which this resource resides

#### Load Balancers

- account - the spinnaker account for this resource
- apiVersion - the kubernetes apiVersion of this resource
- cloudProvider - this will always be `kubernetes`
- detail - the spinnaker detail, if any, for this resource
- displayName - the name of the resource prepared for UI display
- kind - the kubernetes kind of this resource
- manifest - the kubernetes manifest as JSON object
- name - the resource's name
- namespace - the kubernetes namespace in which this resource resides
- stack - the spinnaker stack, if any, for this resource
- type - this resource's spinnaker type

#### Security Groups

- account - the spinnaker account for this resource
- apiVersion - the kubernetes apiVersion of this resource
- application - the spinnaker application name, if any, for this resource
- cloudProvider - this will always be `kubernetes`
- detail - the spinnaker detail, if any, for this resource
- displayName - the name of the resource prepared for UI display
- id - the security group's id
- kind - the kubernetes kind of this resource
- manifest - the kubernetes manifest as JSON object
- name - the resource's name
- namespace - the kubernetes namespace in which this resource resides
- stack - the spinnaker stack, if any, for this resource
- type - this resource's spinnaker type

#### Server Groups

- account - the spinnaker account for this resource
- apiVersion - the kubernetes apiVersion of this resource
- app - the spinnaker application name, if any, for this resource
- category - the spinnaker category, if any, for this resource
- cloudProvider - this will always be `kubernetes`
- cluster - the spinnaker cluster for this resource
- createdTime - the time this resource was created, if available
- detail - the spinnaker detail, if any, for this resource
- disabled - a boolean that is true if this server group is disabled
- disabledDate - a number representing the date this server group was disabled
- displayName - the name of the resource prepared for UI display
- kind - the kubernetes kind of this resource
- manifest - the kubernetes manifest as JSON object
- name - the resource's name
- namespace - the kubernetes namespace in which this resource resides
- region - the region this server group is in
- stack - the spinnaker stack, if any, for this resource
- type - this resource's spinnaker type

#### Server Group Managers

- account - the spinnaker account for this resource
- apiVersion - the kubernetes apiVersion of this resource
- cloudProvider - this will always be `kubernetes`
- displayName - the name of the resource prepared for UI display
- kind - the kubernetes kind of this resource
- manifest - the kubernetes manifest as JSON object
- name - the resource's name
- namespace - the kubernetes namespace in which this resource resides
