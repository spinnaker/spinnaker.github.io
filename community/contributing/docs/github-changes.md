---
layout: single
title: Make a Change Using the GitHub Web UI
sidebar:
  nav: community
---

{% include toc %}

# Open a pull request on GitHub

1. Navigate to the [Spinnaker documentation repository](https://github.com/spinnaker/spinnaker.github.io). Note that the top navigation of Spinnaker.io corresponds to folder names to help you find the file you're looking for.
2. On the page where you see the issue, select the pencil icon at the top right. You can also scroll to the bottom of the page and select **Edit this page**.
3. Make your changes in the GitHub markdown editor.
4. Below the editor, fill in the **Propose file change** form.

  In the **first field**, give your commit message a title that explains what your pull request is about.

  The Spinnaker repositories use a PR title checker, so the title of your PR must follow a specific format: `<type>(<scope>): <subject>`.

  Make sure you include a space after the colon.

  For example:

  ```
   docs(plugins): add documentation for plugin creators
  ```

  For more information, see [commit message guidelines](https://www.spinnaker.io/community/contributing/submitting/#commit-message-conventions).

  In the **second field**, provide a clear and detailed description of your PR. Do not to leave these feilds blank, as it is helpful to reviewers when merging your request to have additional context as to what your pull request is about.

5. Select **propose file change**.

6. Select **create pull request**.
7. After the **open a pull request** screen appears, fill in the form with the following information:

  - The **subject** field of the pull request defaults to the commit summary. Please change this to add a brief summary of your PR changes.
  - The **body** contains some template text. Delete this template text, or feel free to use it to help draft your own extended commit message detailing your pull request. PR descriptions are the first step to helping reviewers and project maintainers understand why your change was made. Any description is better than leaving this field blank, and help get your PR merged faster!
  - Please leave the **allow edits from maintainers** checkbox selected.

# Address feedback in GitHub

Before a pull request is merged, Spinnaker community members will review it. If you have a specific person in mind that you would like to review your pull request, [tag them in the issue comments](https://github.blog/2011-03-23-mention-somebody-they-re-notified/) using the @ symbol and then their GitHub username.

# What to do if you're asked to make changes

1. Go to the **Files changed** tab in GitHub.
2. Make the requested changes.
3. Commit the changes.

# Need help? Get in touch!

If you run into any issues, don't hesitate to reach out to us. We're here to help. Please post a message in the `#sig-documentation` [Slack Channel](https://join.spinnaker.io/), and someone will get back to you!
