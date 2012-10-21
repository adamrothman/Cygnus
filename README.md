# Cygnus
JC, Adam, and Jesse's CS 147 repo.

### Getting the source code
First, you'll need to set up SSH access with GitHub. See https://help.github.com/articles/generating-ssh-keys for details.

    $ git clone git@github.com:adamrothman/Cygnus.git
    $ cd Cygnus
    $ git submodule init
    $ git submodule update
    $ ./tools/install_git_hooks

### Style
Set Xcode to use spaces (the default), with 1 tab equal to 2 spaces (not the default). Opening brackets don't get their own lines. Try to keep line lengths reasonable.

### Working on stuff
Don't work in master. Seriously. Make a branch.

    $ git fetch
    $ git checkout -b my_feature_branch_name origin/master

This fetches the most recent changes and creates a new branch called my_feature_branch_name that tracks the <code>master</code> branch on GitHub. When you <code>git pull</code>, you will get the latest changes from <code>master</code>.

Commit as you go. Keep messages brief, descriptive, and in present tense. Don't use <code>git commit -a</code>; always check what you're committing with <code>git status</code> before you pull the trigger.

    $ git add file_i_changed.m another_file.h
    $ git commit -m "Add some silly files"

If you know what you're doing, you can also use <code>git add -A</code>. When you're done for the night, push your branch to GitHub for safe keeping. Check which branch you're on with <code>git branch</code> before pushing (it's the one with the asterisk). Don't push to <code>master</code>.

    $ git push origin HEAD

You can switch between branches with <code>git checkout branch_name</code>. Make sure your changes are committed first!

### Getting changes into master
Create a pull request. Huzzah for code review! Read https://help.github.com/articles/using-pull-requests and follow the instructions. We are using the "shared repository model." Ask Adam if you have questions.

### Miscellaneous info
Trello list IDs:  
https://api.trello.com/1/board/507fcb93d4b676d0125a723b?token=5a18eedfea7c25571914519f0191038ca0a00e4b5211782e3643c4edfd28b3ac&key=db1e35883bfe8f8da1725a0d7d032a9c&lists=all
