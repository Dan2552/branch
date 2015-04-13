Git branching script
====================
Simple branch switching script to makes git branch switching a bit easier and quicker.

The script makes the assumption that you use a single remote (origin) and your local "my-branch" is always going to have the upstream as "origin/my-branch".

The branch will warn if you have local changes or if the remote branch has diverged and prompt on whether it should continue. If it has diverged it will ask you if you want to keep your local branch or to reset with the remote. 

Usage: `branch my-new-branch`
![Screenshot](https://raw.githubusercontent.com/Dan2552/branch/master/screenshot.png "Screenshot")

Installation
============
```
curl https://raw.githubusercontent.com/Dan2552/branch/master/branch > /usr/local/bin/branch
chmod +x /usr/local/bin/branch
```
