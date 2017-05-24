---
layout: single
title:  "Managed Pipeline Templates"
sidebar:
  nav: setup
---

Spinnaker has a feature to allow templating of common pipelines across
applications. By default, this feature ships disabled.

To enable pipeline templates, modify `orca.yml`:

```yaml
pipelineTemplate:
  enabled: true
```

Once Orca has been launched with pipeline templates enabled, you will need to
create a pipeline that uses a template. You can either write your own following
the [Managed Pipeline Templates Codelab][codelab] or explore the public
[pipeline template repository][template-repo] on GitHub.

[codelab]: [/guides/tutorials/codelabs/managed-pipeline-templates/]
[template-repo]: [https://github.com/spinnaker/pipeline-templates]
