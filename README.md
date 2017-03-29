# Branch

`branch` simplifies the average daily workflow of Git.

By working on simple assumptions of workflow, it's easier, more memorable, quicker and safer to use.

The assumptions `branch` makes are:
- You don't care about staging/unstaging files - y
- You use a single remote (origin) and your local "my-branch" is always going to have the upstream as "origin/my-branch"

## Basic usage

- Use `branch` as an alternative for `git status`
- to change branch, use `branch BRANCH-NAME`

## Features

- When changing branch
  - Warns if you have local changes and prompts on whether to continue
  - Warns if the remote branch has diverged and prompts on whether to continue and if you want to keep your local branch or to reset with the remote
- List most recent branches with `--list` argument

## Future plans

- Recording base branch when creating a new one
- Suggestion to rebase if it detects that you should (i.e. automatic `git pull --rebase` and `git rebase origin/base-branch`)
- Nicer flow for rebasing (visual representation of progress)
- clear indication of files in conflict (as well as automatic indication of when you have resolved them!)
