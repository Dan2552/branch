Branch
======

Branch aims to simplify a developer's daily workflow of Git. It is in no means supposed to replace Git, but provide a quicker and easier way to do some more common functions (with more memorable commands). Branch is pretty opinionated in the way it does things (i.e. I don't care about staging/unstaging files, I just want all of my current changes in a single bucket). It also makes the assumption that you use a single remote (origin) and your local "my-branch" is always going to have the upstream as "origin/my-branch" (i.e. it fits with the most common of workflows).

![Screenshot](https://raw.githubusercontent.com/Dan2552/branch/master/screenshot.png "Screenshot")

Basic usage
=====

- Use `branch` as an alternative for `git status`
- to change branch, use `branch BRANCH-NAME`

Features
========

- When changing branch
  - Warns if you have local changes and prompts on whether to continue
  - Warns if the remote branch has diverged and prompts on whether to continue and if you want to keep your local branch or to reset with the remote
- List most recent branches with `--list` argument

Future plans
============

- Recording base branch when creating a new one
- Suggestion to rebase if it detects that you should (i.e. automatic `git pull --rebase` and `git rebase origin/base-branch`)
- Nicer flow for rebasing (visual representation of progress)
- clear indication of files in conflict (as well as automatic indication of when you have resolved them!)

Building
========

Requirements:
- Carthage `brew install carthage`

Run `make`
