---
layout: single
title: Make a Change Using the GitHub Web UI
sidebar:
  nav: community
---

{% include toc %}

# Open a pull request (PR) on GitHub

1. Click the **Suggest an Edit** link on the documentation page you want to update. This takes you to the page's source file in GitHub.
1. Click the **Edit this file** pencil icon to edit the file.

   ![EditFileIcon](/assets/images/community/contributing/docs/github-edit-file-icon.jpg)

1. Make your changes in the GitHub markdown editor.
1. Fill in the **Propose file change** form.

   ![ProposeFileChange](/assets/images/community/contributing/docs/github-propose-file-change-form.jpg)

   1. Explain what your file change is about in a short summary.

   2. Provide a clear description of your change. Do not to leave this field blank. It is helpful to reviewers to have additional context about what you changed.

1. Click **Propose file change**. This takes you to the **Comparing changes** screen so you can review your changes.

1. Click **Create pull request**. This takes you to the **Open a pull request** form.

1. Fill in the **Open a pull request** form.

   ![OpenPullRequest](/assets/images/community/contributing/docs/github-open-pull-request.jpg)

   1. The **Title** defaults to the file change summary. Update the title so it follows the `<type>(<scope>): <subject>` format. Make sure you include a space after the colon. For example:

      ```
      docs(plugins): add documentation for plugin creators
      ```

      The Spinnaker repositories use a PR title checker, so your PR will fail if the title is not in the correct format. For more information, see [commit message conventions](/community/contributing/submitting/#commit-message-conventions).

   2. The **Leave a comment** field defaults to the file change description. PR descriptions are the first step to helping reviewers and project maintainers understand why your change was made. Do not leave this field blank. Provide as much description as possible. A good description helps get your PR merged faster!

   3. Leave the **Allow edits from maintainers** checkbox selected.

# Address feedback in GitHub

Spinnaker community members will review your pull request. If you have a specific person in mind, [tag them in the issue comments](https://github.blog/2011-03-23-mention-somebody-they-re-notified/) using the @ symbol and then their GitHub username. Reviewers can request changes, leave comments, or approve the pull request.

# What to do if a reviewer asks for changes

1. Go to the **Files changed** tab in GitHub.
1. Make the requested changes.
1. Commit the changes.

# Need help? Get in touch!

Don't hesitate to reach out to the Docs team if you run into any issues. We're here to help. Post a message in the `#sig-documentation` [Slack Channel](https://app.slack.com/client/T091CRSGH/CMPS49682), and someone will get back to you!
