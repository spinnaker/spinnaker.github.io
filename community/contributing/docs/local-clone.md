---
layout: single
title: Make a Change Using the GitHub Web UI
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

1. Fetch commits from your fork's `origin/master` and `spinnaker/spinnaker.github.io`'s `upstream/master`:

   ```bash
   git fetch origin
   git fetch upstream
   ```

   This makes sure your local repository is up to date before you start making changes.

   >This workflow is different from a source code commit workflow . You do not need to rebase your local copy of `master` with `upstream/master` before pushing updates to your fork. In the documentation workflow, you create a branch that tracks changes to `upstream/master` rather than `origin/master`.

## Create a working branch

1. Create a new branch based on `upstream/master`:

   ```bash
   git checkout -b <my-new-branch> upstream/master
   ```

1.  Make your changes.

Use the `git status` command at any time to see what files you've changed.

## Preview your changes locally

It's a good idea to preview your changes locally before pushing them or opening a pull request. A preview lets you catch build errors or markdown formatting problems. See the `spinnaker.github.io` [README](https://github.com/spinnaker/spinnaker.github.io/blob/master/README.md) for instructions on how to install Jekyll and generate a local preview.

## Commit your changes

Commit your changes when you are ready to submit a pull request.

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
   git commit -m "Your commit message"
   ```

   Your commit message can have a max of 50 characters.

   > Do not use any [GitHub
   Keywords](https://help.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword) in your commit message. You can add those to the pull request description later.

1. Push your local branch and its new commit to your remote fork:

   ```bash
   git push origin <my-new-branch>
   ```

## Open a pull request from your fork to spinnaker/spinnaker.github.io

1. In a web browser, go to the [`spinnaker/spinnaker.github.io`](https://github.com/spinnaker/spinnaker.github.io) repository.
1. Select **New Pull Request**.
1. Select **compare across forks**.
1. From the **head repository** drop-down menu, select your fork.
1. From the **compare** drop-down menu, select your branch.
1. Select **Create Pull Request**.
1. Add a description for your pull request:
   - **Title** (50 characters or less): Summarize the intent of the change.
   - **Description**: Describe the change in more detail.
     - If there is a related GitHub issue, include `Fixes #12345` or `Closes #12345` in the description. GitHub's automation closes the mentioned issue after merging the PR if used. If there are other related PRs, link those as well.
     - If you want advice on something specific, include any questions you'd like reviewers to think about in your description.

1. Select the **Create pull request** button.

  Congratulations! Your pull request is available in [Pull requests](https://github.com/kubernetes/website/pulls).


After opening a PR, GitHub runs automated tests and tries to deploy a preview using [Netlify](https://www.netlify.com/).

  - If the Netlify build fails, select **Details** for more information.
  - If the Netlify build succeeds, select **Details** opens a staged version of the Kubernetes website with your changes applied. This is how reviewers check your changes.

GitHub also automatically assigns labels to a PR, to help reviewers. You can add them too, if needed. For more information, see [Adding and removing issue labels](/docs/contribute/review/for-approvers/#adding-and-removing-issue-labels).

## Addressing feedback locally

1. After making your changes, amend your previous commit:

   ```bash
   git commit -a --amend
   ```

   - `-a`: commits all changes
   - `--amend`: amends the previous commit, rather than creating a new one

2. Update your commit message if needed.

3. Use `git push origin <my_new_branch>` to push your changes and re-run the Netlify tests.

   {{< note >}}
     If you use `git commit -m` instead of amending, you must [squash your commits](#squashing-commits) before merging.
   {{< /note >}}

### Changes from reviewers

Sometimes reviewers commit to your pull request. Before making any other changes, fetch those commits.

1. Fetch commits from your remote fork and rebase your working branch:

   ```bash
   git fetch origin
   git rebase origin/<your-branch-name>
   ```

2. After rebasing, force-push new changes to your fork:

   ```bash
   git push --force-with-lease origin <your-branch-name>
   ```

### Merge conflicts and rebasing

{{< note >}}
For more information, see [Git Branching - Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging#_basic_merge_conflicts), [Advanced Merging](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging), or ask in the `#sig-docs` Slack channel for help.
{{< /note >}}

If another contributor commits changes to the same file in another PR, it can create a merge conflict. You must resolve all merge conflicts in your PR.

1. Update your fork and rebase your local branch:

   ```bash
   git fetch origin
   git rebase origin/<your-branch-name>
   ```

   Then force-push the changes to your fork:

   ```bash
   git push --force-with-lease origin <your-branch-name>
   ```

2. Fetch changes from `kubernetes/website`'s `upstream/master` and rebase your branch:

   ```bash
   git fetch upstream
   git rebase upstream/master
   ```

3. Inspect the results of the rebase:

   ```bash
   git status
   ```

  This results in a number of files marked as conflicted.

4. Open each conflicted file and look for the conflict markers: `>>>`, `<<<`, and `===`. Resolve the conflict and delete the conflict marker.

   {{< note >}}
   For more information, see [How conflicts are presented](https://git-scm.com/docs/git-merge#_how_conflicts_are_presented).
   {{< /note >}}

5. Add the files to the changeset:

   ```bash
   git add <filename>
   ```
6.  Continue the rebase:

   ```bash
   git rebase --continue
   ```

7.  Repeat steps 2 to 5 as needed.

   After applying all commits, the `git status` command shows that the rebase is complete.

8. Force-push the branch to your fork:

   ```bash
   git push --force-with-lease origin <your-branch-name>
   ```

   The pull request no longer shows any conflicts.
