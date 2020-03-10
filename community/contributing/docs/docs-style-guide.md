---
layout: single
title:  "Documentation Style Guide"
sidebar:
  nav: community
---

{% include toc %}


This page gives writing style guidelines for the Spinnaker documentation. Since these are guidelines, not rules, use your best judgment when creating content. Feel free to propose changes to this document in a pull request.

If you have a style question that isn't answered in this guide, ask the SIG Docs team in the `#sig-documentation` channel.

## Language

The Spinnaker documentation uses U.S. English spelling and grammar. However, use the international standard for punctuation inside quotes.

|**Do** |**Do Not**|
|:------|:---------|
| Your copy of the repo is called a "fork". | Your copy of the repo is called a "fork." |

Create content using [Markdown](https://www.markdownguide.org/) with your favorite IDE.

## Best practices for clear, concise, and consistent content

### Use present tense

|**Do** |**Do Not**|
|:------|:---------|
| This command adds a plugin. 	| This command will add a plugin. 	|

Exception: Use future or past tense if it is required to convey the correct meaning.

### Use active voice

|**Do** |**Do Not**|
|:------|:---------|
| You can explore the API using a browser. | The API can be explored using a browser. |
| Orca supports the following storage backends for storing execution state: | The following storage backends are supported for storing execution state: |

Exception: Use passive voice if active voice leads to an awkward construction.

### Use simple and direct language

Use simple and direct language. Avoid using unnecessary phrases like "please".

|**Do** |**Do Not**|
|:------|:---------|
| To create an Artifact, ... | In order to create an Artifact, ...|
| See the configuration file. | Please see the configuration file.|
| View the Pipeline logs. | With this next command, we'll view the Pipeline logs.|

### Address the reader as "you"

|**Do** |**Do Not**|
|:------|:---------|
| You can create a Pipeline by ... | We'll create a Pipeline by ...|
| In the preceding output, you see... | In the preceding output, we see ...|

### Avoid Latin phrases

Use English terms over Latin abbreviations.

|**Do** |**Do Not**|
|:------|:---------|
| For example, ... | e.g., ...|
| That is, ...| i.e., ...|

Exception: Use "etc." for et cetera.

### Paragraphs

Try to keep paragraphs short, under 6 sentences, and limit to a single topic.

### Links

Use hyperlinks that give the reader context for the linked content. Avoid ambiguous phrases like "click here" in favor of descriptive ones.

For example, use
~~~~~~~~~~
See the [Repository structure](https://github.com/pf4j/pf4j-update#repository-structure) section of the PF4J README for details.
~~~~~~~~~~

rather than
~~~~~~~~~~
Click [here](https://github.com/pf4j/pf4j-update#repository-structure) to read more.
~~~~~~~~~~

For long URLs, consider using [reference-style hyperlinks](RefStyleLinkDoc) to maintain readability of the Markdown file.

## Patterns to avoid

### Avoid using "we"

Do not use "we" because readers may not know if they are part of the "we".

|**Do** |**Do Not**|
|:------|:---------|
| Version 1.19.0 includes ... | In version 1.19.0, we have added ...
| Spinnaker provides a new feature for ... | We provide a new feature for ...|
| This guide teaches you how to use Plugins. | In this guide, we are going to learn about Plugins.|

### Avoid jargon and idioms

Avoid jargon and idioms to help non-native English speakers understand the content better.

|**Do** |**Do Not**|
|:------|:---------|
| Internally, ...| Under the hood, ...|
| Create a new instance. | Spin up a new instance.|

### Avoid statements about the future

If you need to write about an alpha feature, put the text in a note or under a heading that identifies it as alpha information.

### Avoid statements that will soon be out of date

Avoid using words like "currently" and "new." A feature that is new today might not be considered new in a few months.

|**Do** |**Do Not**|
|:------|:---------|
| In version 1.4, ... | In the current version, ...|
| The Plugins feature provides ... | The new Plugin feature provides ...|

## Documentation formatting standards

### Use sentence capitalization for headings

~~~~~~~~~
# Creating a custom webhook stage

## Configuring parameters for custom webhook stages
~~~~~~~~~

### Line breaks
U#se a single newline to separate block-level content like headings, lists, images, code blocks, paragraphs, and others.

### Use camel case for API objects

Use the same uppercase and lowercase letters that are used in the
actual object name when you write about API objects. The names of API objects use [Camel case](https://en.wikipedia.org/wiki/Camel_case).

Don't split the API object name into separate words. For example, use CredentialsController, not Credentials Controller.

Refer to API objects without saying "object," unless omitting "object" leads to an awkward construction.

|**Do** |**Do Not**|
|:------|:---------|
| The PipelineController restarts a Stage. | The pipeline controller restarts a stage.|
| The AmazonInfrastructureController is responsible for ... | The AmazonInfrastructureController object is responsible for ...|

### Use angle brackets for placeholders

Use angle brackets for placeholders. Describe what a placeholder represents.

For example:
`hal plugins repository add <unique-repo-name> --url <repo-url>`


### Use bold for user interface elements

|**Do** |**Do Not**|
|:------|:---------|
| Click **Fork**.| Click "Fork".|
| Select **Other**. | Select "Other".|


### Use italics to define or introduce new terms

|**Do** |**Do Not**|
|:------|:---------|
|A _Stage_ is a step in a pipeline ... | A "Stage" is a step in a pipeline ...|

### Use code style for filenames, directories, and paths

|**Do** |**Do Not**|
|:------|:---------|
| Open the `rosco.yaml` file. | Open the rosco.yaml file.|
| Go to the `/docs/tutorials` directory. | Go to the /docs/tutorials directory.|
| Open the `/.hal/config` file. | Open the /.hal/config file.|

### Lists
Group items in a list that are related to each other. Use a numbered list for instructions that need to be completed in a specific order.

 - End each item in a list with a period if one or more items in the list are complete sentences. For the sake of consistency, normally either all items or none should be complete sentences.
 - Use the number one (1.) for ordered lists.
 - Use (+), (* ), or (-) for unordered lists.
 - Leave a blank line after each list.
 - Indent nested lists with four spaces (for example, ⋅⋅⋅⋅).
 - List items may consist of multiple paragraphs. Each subsequent paragraph in a list item must be indented by either four spaces or one tab.
 - The first line of a code block should be indented four spaces

For example, an ordered list with a code block looks like this in Markdown:
~~~
1. Do this
1. Do this
1. Do this
1. Run these commands:

    ```
	  curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
	  sudo bash InstallHalyard.sh
	```

1. Do the next thing
~~~

The rendered output look like:

1. Do this
1. Do this
1. Do this
1. Run these commands:

    ```
	curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
	sudo bash InstallHalyard.sh
	```

1. Do the next thing

## Inline code formatting

### Use code style for inline code and commands

Use meaningful variable names that have a context rather than  'foo','bar', and similar meaningless variable names.

Use a single backtick (\`) to surround inline code in a Markdown document. In Markdown:
~~~~~~~~~
Run `hal deploy apply` to deploy Spinnaker.
~~~~~~~~~

Use triple backticks to enclose a code block. In Markdown:
~~~~~~~~~
```json
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```
~~~~~~~~~

Remove trailing spaces in all code blocks.

### Don't include the command prompt in code snippets

|**Do** |**Do Not**|
|:------|:---------|
hal deploy apply| $ hal deploy apply

### Separate commands from output

Verify that the Pod is running on your chosen node:

    kubectl get pods --output=wide

The output is similar to this:

    NAME     READY     STATUS    RESTARTS   AGE    IP           NODE
    nginx    1/1       Running   0          13s    10.200.0.4   worker0

### Use normal style for string and integer field values

For field values of type string or integer, use normal style without quotation marks.

|**Do** |**Do Not**|
|:------|:---------|
Set the value of `enabled` to True. | Set the value of `enabled` to "True".
Set the value of `image` to nginx:1.8. | Set the value of `image` to `nginx:1.8`.

## Versioning Spinnaker examples

Code examples and configuration examples that include version information should be consistent with the accompanying text.

If the information is version specific, the Spinnaker version needs to be defined in the `Prerequisites` section of the guide.

## Spinnaker.io word list

A list of Spinnaker-specific terms and words to be used consistently across the site:

| **Do**                         | **Do Not**                                                         |
|:------------------------------ |:------------------------------------------------------------------ |
| Kubernetes                     | kubernetes                           |
| Docker                         | docker                               |
| SIG Docs                       | SIG Docs rather than SIG-DOCS or other variations.                 |
| On-premises                    | On-premises or On-prem rather than On-premise or other variations. |
| Halyard                        | halyard                                                                   |
| Operator or Spinnaker Operator | operator or Spinnaker operator  |                                                                 



[RefStyleLinkDoc]: https://www.markdownguide.org/basic-syntax/#reference-style-links
