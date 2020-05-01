---
layout: single
title: Make a Change Using a Local Clone
sidebar:
  nav: community
---

{% include toc %}


If you're more experienced with git, or if your changes are larger than a few
lines, work from a local fork. Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed on your computer.

## Fork the Spinnaker documentation repository

1. Navigate to the [`spinnaker/spinnaker.github.io`](https://github.com/spinnaker/spinnaker.github.io/) repository.
1. Select **Fork**.

## Create a local clone and set the upstream repository

1. In a terminal window, clone your fork:

   ```bash
   git clone git@github.com/<github_username>/spinnaker.github.io
   ```

1. Navigate to the new `spinnaker.github.io` directory. Set the `spinnaker/spinnaker.github.io` repository as the `upstream` remote:

   ```bash
   cd spinnaker.github.io

   git remote add upstream https://github.com/spinnaker/spinnaker.github.io.git
   ```

1. Confirm your `origin` and `upstream` repositories:

   ```bash
   git remote -v
   ```

   Output is similar to:

   ```bash
   origin	git@github.com:<github_username>/spinnaker.github.io.git (fetch)
   origin	git@github.com:<github_username>/spinnaker.github.io.git (push)
   upstream	https://github.com/spinnaker/spinnaker.github.io (fetch)
   upstream	https://github.com/spinnaker/spinnaker.github.io (push)
   ```

## Update your local repository

You should make sure your local repository is up to date before you start making changes. Fetch commits from your fork's `origin/master` and `spinnaker/spinnaker.github.io`'s `upstream/master`:

   ```bash
   git fetch origin
   git fetch upstream
   ```

   >This workflow is different from a source code commit workflow . You do not need to rebase your local copy of `master` with `upstream/master` before pushing updates to your fork. In the documentation workflow, you create a working branch that tracks changes to `upstream/master` rather than `origin/master`.

## Create a working branch

1. Create a new working branch based on `upstream/master`:

   ```bash
   git checkout -b <your-working-branch> upstream/master
   ```

1.  Make your changes.

Use the `git status` command at any time to see what files you've changed.

## Preview your changes locally

It's a good idea to preview your changes locally before pushing them or opening a pull request. A preview lets you catch build errors or markdown formatting problems. See the `spinnaker.github.io` [README](https://github.com/spinnaker/spinnaker.github.io/blob/master/README.md) for instructions on how to install Jekyll and generate a local preview.

## Commit your changes

Commit your changes when you are ready to submit a pull request (PR).

1. Check which files you need to commit:

   ```bash
   git status
   ```

   Output is similar to:

   ```bash
   On branch local-clone
   Changes not staged for commit:
   (use "git add <file>..." to update what will be committed)
   (use "git restore <file>..." to discard changes in working directory)

   modified:   _data/navigation.yml

   Untracked files:
   (use "git add <file>..." to include in what will be committed)

   community/contributing/docs/local-clone.md

   no changes added to commit (use "git add" and/or "git commit -a")
   ```

1. Add new files listed under **Untracked files** to the commit:

   ```bash
   git add <your_file_name>
   ```

   Repeat this for each file.

1.  Create a commit:

   ```bash
   git commit -a -m <your-commit-subject> -m <your-commit-description>
   ```

   - `-a`: Commits all changes.
   - `-m`: Use the given <msg> as the commit message. If multiple -m options are given, their values are concatenated as separate paragraphs.

   Your commit messages must be 50 characters or less.

   > Do not use any [GitHub
   Keywords](https://help.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword) in your commit message. You can add those to the pull request description later.

1. Push your working branch and its new commit to your remote fork:

   ```bash
   git push origin <your-working-branch>
   ```

## Open a pull request from your fork to spinnaker/spinnaker.github.io

1. In a web browser, go to the [`spinnaker/spinnaker.github.io`](https://github.com/spinnaker/spinnaker.github.io) repository. You should see your recently pushed working branch and a **Compare & pull request** button.

   ![CompareAndPullRequest](/assets/images/community/contributing/docs/compare-and-pr.jpg)

1. Click **Compare & pull request**. This takes you to the **Open a pull request** screen.

   ![OpenPullRequest](/assets/images/community/contributing/docs/github-open-pull-request.jpg)

   1. The **Title** defaults to the commit subject. Update the title so it follows the `<type>(<scope>): <subject>` format. Make sure you include a space after the colon. For example:

   ```
   docs(plugins): add documentation for plugin creators
   ```

   The Spinnaker repositories use a PR title checker, so your PR will fail if the title is not in the correct format. For more information, see [commit message conventions](/community/contributing/submitting/#commit-message-conventions).

   2. The **Leave a comment** field defaults to the commit description. Pull request descriptions are the first step to helping reviewers and project maintainers understand why your change was made. Do not leave this field blank. Provide as much description as possible. A good description helps get your PR merged faster!
   3. Leave the **Allow edits from maintainers** checkbox selected.
   4. Click the **Create pull request** button.

   Congratulations! You can view your submitted pull request on the **Pull requests** [tab](https://github.com/spinnaker/spinnaker.github.io/pulls).

   >Do not delete your working branch until your pull request has been merged!

## Addressing feedback locally

Reviewers may ask you to make changes to your pull request. Read the feedback and make changes in your working branch.

1. After making your changes, create a new commit:

   ```bash
   git commit -a -m <your-commit-subject> -m <your-commit-description>
   ```

1. Push your changes:

   ```bash
   git push origin <your-working-branch>
   ```

## Changes from reviewers

Sometimes reviewers commit to your pull request. Fetch those commits before making any other changes.

1. Fetch commits from your remote fork and rebase your working branch:

   ```bash
   git fetch origin
   git rebase origin/<your-working-branch>
   ```

1. After rebasing, force-push new changes to your fork:

   ```bash
   git push --force-with-lease origin <your-working-branch>
   ```

### Merge conflicts and rebasing

>For more information, see [Git Branching - Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging#_basic_merge_conflicts), [Advanced Merging](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging), or ask in the `#sig-documentation` Slack channel for help.

If another contributor commits changes to the same file in another PR, it can create a merge conflict. You must resolve all merge conflicts in your PR.

1. Update your fork and rebase your working branch:

   ```bash
   git fetch origin
   git rebase origin/<your-working-branch>
   ```

   Then force-push the changes to your fork:

   ```bash
   git push --force-with-lease origin <your-working-branch>
   ```

1. Fetch changes from `spinnaker/spinnaker.github.io`'s `upstream/master` and rebase your branch:

   ```bash
   git fetch upstream
   git rebase upstream/master
   ```

1. Inspect the results of the rebase:

   ```bash
   git status
   ```

  This results in a number of files marked as conflicted.

1. Open each conflicted file and look for the conflict markers: `>>>`, `<<<`, and `===`. Resolve the conflict and delete the conflict marker.

   >For more information, see [How conflicts are presented](https://git-scm.com/docs/git-merge#_how_conflicts_are_presented).

1. Add the files to the changeset:

   ```bash
   git add <filename>
   ```

1.  Continue the rebase:

   ```bash
   git rebase --continue
   ```

1.  Repeat steps 2 to 5 as needed.

   After applying all commits, the `git status` command shows that the rebase is complete.

1. Force-push your working branch to your remote fork:

   ```bash
   git push --force-with-lease origin <your-working-branch>
   ```

   The pull request no longer shows any conflicts.
