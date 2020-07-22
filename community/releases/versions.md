---
layout: single
title:  "Versions"
sidebar:
  nav: community
---

The Spinnaker releases listed below are top-level versions tying together each
Spinnaker subcomponents' versions. These have been validated together in an
end-to-end integration test suite curated by the Spinnaker community, and
represent a more maintainable, easy to upgrade Spinnaker. While
it's still possible to install each Spinnaker subcomponent's versions
independently, there is no guarantee that they will work together.

If you want to see what each top-level version is comprised of, run

```bash
hal version bom <version>
```

to see the commit hash and tag matching `version-<version>` of each
subcomponent.

## Latest stable

**Note**: In upcoming versions, Spinnaker will be migrating to Java 11 from Java 8. This should not affect Spinnaker users. If you extend Spinnaker, this may affect you. For more information about the current status of the migration, see the [Java 11 RFC](https://github.com/spinnaker/governance/blob/master/rfc/java11.md).
{: .notice--info}

**Note**: Spinnaker versions 1.18.0 and later require Halyard version 1.29.0 or later.
{: .notice--info}

{% assign reversed = site.changelogs | sort: 'date' | reverse  %}
{% for post in reversed %}
  {% unless post.tags contains 'deprecated' %}
{% if post.version == blank %}
#### {{ post.changelog_title }}
{% else %}
#### Version {{ post.version }}
{% endif %}
Released: {{ post.date | date: '%Y-%m-%d %H:%M %Z' }}
<a href="{{ post.url }}">Changelog</a>
  {% endunless %}
{% endfor %}

> To be notified when new Spinnaker versioned releases are available, please join the
[spinnaker-announce](https://groups.google.com/forum/#!forum/spinnaker-announce) Google
Group (requires a Google account).

## Deprecated Versions
{% for post in reversed %}
  {% if post.tags contains 'deprecated' %}
#### {{ post.changelog_title }}
Released: {{ post.date | date: '%Y-%m-%d %H:%M %Z' }}
<a href="{{ post.url }}">Changelog</a>
  {% endif %}
{% endfor %}
