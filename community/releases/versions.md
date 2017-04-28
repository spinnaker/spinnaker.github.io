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
Released: {{ post.date }}  
<a href="{{ post.url }}">Changelog</a>
  {% endunless %}
{% endfor %}

## Deprecated
{% for post in reversed %}
  {% if post.tags contains 'deprecated' %}
#### {{ post.title }}  
Released: {{ post.date }}  
<a href="{{ post.url }}">Changelog</a>
  {% endif %}
{% endfor %}
