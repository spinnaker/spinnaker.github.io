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

By default, the pipeline instance inherits the stages, expected artifacts, triggers, parameters, and notifications from the template.
It's possible to opt out of inheriting triggers, parameters, and notifications by including the corresponding string in the `exclude` element.

For example, the template might have a trigger defined in the `triggers` element, but you can opt out of inheriting it by including `triggers` inside the `exclude` element.

1. In the pipeline template you are instantiating, examine what's in the
`pipeline` element to see what you want to use in your pipeline.

   ```bash
   spin pipeline-template get --id <templateName>
   ```

1. In the `exclude: [] ` section of the pipeline JSON, include the key for
each element of the template that you want to opt out of inheriting.

   For example, to opt out of inheriting triggers defined in `pipeline.triggers`, include
   `triggers` inside the `exclude` element of the new pipeline:

   ```json
   "exclude": ["triggers"]
   ```

   The same goes for other items found inside `pipeline`.

   ```json
   "exclude": ["triggers", "notifications"] # for example
   ```   

Now, all the triggers and notificatons (in this example) defined in the template are excluded from the pipeline instance.

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