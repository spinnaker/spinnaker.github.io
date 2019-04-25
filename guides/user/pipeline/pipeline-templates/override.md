---
layout: single
title:  "Inherit from the Template or Override It"
sidebar:
  nav: guides
---

{% include toc %}

In a pipeline that instantiates a template, besides providing values for
template variables you can...

* [Inherit](#inherit-from-the-template) features from the template
* [Override](#override-the-template) (add to) inherited features.

## Inherit from the template

By default, the pipeline instance inherits from `pipeline.stages` only. The
pipeline does not inherit any other items defined in the template. You have to
explicitly identify anything else from the template you want to inherit. 

For example, the template might have a trigger defined in the
`triggers` element, but that trigger is not used in your pipeline unless you
include `triggers` inside the `inherit` element.

1. In the pipeline template you are instantiating, examine what's in the
`pipeline` element to see what you want to use in your pipeline.

   ```bash
   spin pipeline-template get --id <templateName>
   ```

1. In the `inherit: [] ` section of the pipeline JSON, include the key for
each element of the template that you want to inherit.

   For example, to inherit triggers defined in `pipeline.triggers`, include
   `triggers` inside the `inherit` element of the new pipeline:

   ```json
   "inherit": ["triggers"]
   ```

   The same goes for anything else found inside `pipeline`.

   ```json
   "inherit": ["triggers", "notifications"] # for example
   ```   

Now, all the triggers and notificatons (in this example) defined in the template are part of the pipeline instance.

## Override the template

To override an element from a pipeline template is to *add to* that element.
You can only override an element if you inherit it, and you can only add to
it&mdash;you can't remove or edit individual members.

The stage definitions inside `stages` are inherited by default. You can add
further stages, and the configuration required to wire added stages with
inherited stages.

1. Make sure you're inheriting from the element or elements you want to
override. 

   [See above](#inherit-from-the-template)

   Also, as mentioned above, stages defined in the tempate are inherited by
   default.

1. Add any triggers, notifications, parameters, etc., inside their respective elements.

These items are now *added* to those inherited from the template.