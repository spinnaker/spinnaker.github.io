---
layout: single
title:  "Versions"
sidebar:
  nav: community
---

## Latest Stable
{% assign reversed = site.changelogs | reverse |  %}
{% for post in reversed %}
  {% unless post.tags contains 'deprecated' %}
#### {{ post.title }}  
Released: {{ post.date | date_to_rfc822 }}  
<a href="{{ post.url }}">Changelog</a>
  {% endunless %}
{% endfor %}

### Deprecated Versions
{% for post in reversed %}
  {% if post.tags contains 'deprecated' %}
#### {{ post.title }}  
Released: {{ post.date }}  
<a href="{{ post.url }}">Changelog</a>
  {% endif %}
{% endfor %}
