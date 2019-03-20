---
layout: single
title:  "Parameterize a Pipeline Template"
sidebar:
  nav: guides
---

{% include toc %}

Given a pipeline template, created based on an existing pipeline that's similar
to what you want to the template to look like, you can create variables for any
of the values in that pipeline template.

## Figure out what values to parameterize

You can parameterize values that are inside the `pipeline.stages` element of
the template.

You can't do so with the pipeline config. For example, you can't create a
variable for the pipeline name, triggers, and so on.

## Declare your template variables 

In the `variables` section of your pipeline template JSON, add an entry for
each variable you're going to
[reference](#add-referencences-to-those-variables) in the `pipeline` section.
Here's the format:

```json
{
  "type" : "<type>",
  "defaultValue" : <defaultValue>,
  "description" : "<some description>",
  "var1Name" : "<name of this variable"
} 
```

## Add Referencences to those variables

In the `pipeline.stages` section of the template JSON, for each stage, there is
an identifier for the value you've variableized. In a non-templated pipeline,
it's followed by the value:

`“timeToWait” : “60”`

In a parameterized template, it's followed by a SpEL expression that resolves
to the value:

`“waitTime” : “${ templateVariables.timeToWait }”`

The variable must be [declared](#declare-your-template-variables) in the
`variables` section.