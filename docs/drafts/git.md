# GIT Notes

## Resources

- <https://git-scm.com/docs>

## Guidance

### Don’t push your work until you’re happy with it

One of the cardinal rules of Git is that, since so much work is local within your clone, you have a great deal of freedom to rewrite your history locally. However, once you push your work, it is a different story entirely, and you should consider pushed work as final unless you have good reason to change it. In short, you should avoid pushing your work until you’re happy with it and ready to share it with the rest of the world.

But this is a problem for solo developers that use push as your backup. Another way to interpret it and maintain the intent, is don't push to shared branches or repos until you are happy with your work. Your feature branches are yours and you can and should place work in progress (WIP) in there all day!

## Shortcuts and Must Know Commands

HEAD is the pointer to the current branch reference, which is in turn a pointer to the last commit made on that branch. That means HEAD will be the parent of the next commit that is created. It’s generally simplest to think of HEAD as the snapshot of your last commit on that branch.

Shorthand Means
HEAD Current branch tip
@ Same as HEAD (even shorter)
HEAD~1 One commit before HEAD (parent)
HEAD~2 Two commit before HEAD (grandparent)
HEAD~n `n` commits back
HEAD^ First parent (same as ~1 for linear history)
origin/HEAD default branch (e.g., main)
'-' Previous branch you were on (works with git checkout - or git switch -)

You can evaluate various shortcuts using the `git rev-parse` command.

`git reflog`

## Scenarios

### Merging by Rebase

Say you have been working on a feature branch and you want to see how many commits ahead of main or another branch you are.

```bash
# Count commits on feature that are not in main
git log --oneline main..<branch_name>

# If the branch in question is currently checked out, can be reduced to one of following
git log --oneline main..HEAD
git log --oneline main..@
git log --oneline main..

# To get count of changes
git rev-list --count main..
git log --oneline main.. | wc -l
```

Now you want to see if the branch you started your feature on has progressed. If the parent branch has not progressed (0 count), fast-forward merge is possible.

Rebase puts your commits on top of the target, making the target a direct ancestor. After that, a fast-forward merge becomes possible, but you still have to do the merge step yourself.

```bash
git log --oneline @..main
git log rev-list --count @..main
```

You realize that there are some old branches that are stale, abandoned or contain no work and should be deleted.

```bash
# If a branch is 0 commits ahead, it is a dead branch and can likely be deleted
git branch -d <list_of_branches>
git push origin --delete <list_of_branches>
```

### Merge feature branch

You identify another branch that legitimately needs to be merged in with another (i.e., main). For simplicity, assume attempting to merge "feature/branch" onto "main".

```bash
src="feature/branch"
dst="main"

# Obtain the base fork point of where branch started
base=$(git merge-base $src $dst)

# Check to see destination has not changed since base fork point. If no changes, clean fast-forward.
git rev-list --count $base..$dst

# Preview commits to merge
git log --oneline $dst..$src

## Cleanup commits before merging (optional, jump to merge if not needed)
git checkout $src
# Provide parent of the last commit to edit. Commits are listed oldest at the top. Interactive generates a "git-rebase-todo" file. If the todo file is modified, the instructions are executed.
git rebase --interactive $dst

# The instructions are written to .git/rebase-merge/git-rebase-todo. The instructions can be modified while a rebase is in progress
git rebase --edit-todo

# Interactive rebase can be run iteratively. Repeat as many times as needed. For example, first pass my be to pick+squash+fixup, second pass squash and reorder, third pass reword messages.

# Check your work to make sure you didn't accidentally drop or improperly merge commits
git diff origin/$src..$src

# Once you are happy with your rebase, you can push to your remote
git push --force-with-lease origin $src

# Merge Commits
git checkout $dst
git merge --ff-only $src

# Check commits for consistency
git log --oneline origin/$dst..$dst

# Check no unintended file changes snuck in
git diff origin/$dst..$dst --stat

git push origin $dst

# Delete feature branch after merge
git branch -d $src

# Delete remote
git push origin --delete $src
```

A couple of observations. Commands like `diff` and `log` take reference names that resolve to specific commit hashes. Whereas command like `push` takes arguments of repos "send this branch to that server". This difference is why you see "origin" used differently depending on the command. Origin means two different things depending on the context. The remote tracking branch and the remote itself.

Now assume that you have some additional WIP feature branches (e.g., `$src`) that were also based off the the previous example `$base` commit. If you were to compare how many commits there are between the new `$src` and the revised `dst` the quantity likely contains the commits from the previous merge. We can fix this by rebasing `$dst` onto the new `$src`.

```bash
src=feature/wip_branch
dst="main"

git checkout "$src"
git rebase "$dst"
```

If you hit a merge conflict, no worries but be aware that during a rebase, the merge markers are flipped from what you'd expect. HEAD is the argument to rebase (i.e., `$dst`) and source is the feature branch. This is because rebase works by first checking out the target (i.e., `$dst`) which becomes HEAD then replaying commits from the feature branch one at a time. So at the moment of conflict, git is sitting on `$dst` (HEAD) and trying to apply your feature commits from `$src` on top. From git's perspective, HEAD is `$dst` during the operation.

```bash
# Quickly display conflicts
cat <conflicted_file> | grep -A 10 "<<<<<<<"
```

When handling merge conflicts, it is often a good idea to pause and ponder why. Do you understand the nature of the conflict? In this particular scenario, the conflict came from the previous interactive rebase. If the initial merge conflicts were manually resolved, a similar process would have been needed again to handle conflict yet again. This is because the previous interactive rebase reordered commits to clean up history. In this case, there is an easier way! Perform another interactive baseline on the shared merge-base, squash all the old work (we don't care about order) then attempt a rebase again from `$dst`.

```bash
src=feature/wip_branch
dst="main"

# Find common base between feature branch and target branch
base=$(git merge-base "$src" "$dst")

# Inspect deltas (should look familiar from previous feature merge)
git rev-list --count "$dst"..
git log --oneline "$dst"..

# Checkout feature branch
git checkout $src

# Squash changes already merged using interactive rebase. Edit first line, set middle to squash, and keep the tail (your WIP).
git rebase --interactive "$base"

# Rebase from target
git rebase "$dst"

# Push work
```

In general you have several options (general)

- Squash and merge (fast and easy for some situations)
- Cherry pick and merge
- Manual resolve conflict (potentially slow and error prone)
- Brute force

### Fixing Issues

Generally, you want to create a new branch for each independent bug fix. Occasionally, a single branch may include fixes for multiple issues if they are effecting the same area of code and cannot be tested independently.

When creating bug fix branches, prefix them with "fix" (e.g., "fix/recipe-cfg"). Ideally, feature and fix branches are short lived. As such, use short names. Each fix branch should be created from the default branch, presumably the branch with the issue, unless there is a concrete reason not to. **NEVER** stack fix branches on each other as it makes it much more difficult to merge later.

```bash
git checkout main

git checkout --branch fix/recipe-config
git checkout --branch fix/reactor-timing
```

Sometimes you may want to test or evaluate multiple bug fixes together in a single branch. This strategy deliberately generates merge commits. They are quick and easy and keeps the individual fixes independent. Rebase would be wrong here because it would rewrite the fix branch commits onto each other, creating artificial dependencies between independent fixes.

```bash
git checkout main

git checkout --branch test/combined-fix

git merge fix/recipe-config
git merge fix/reactor-timing
```

After successful testing, merge back.

```bash
git checkout main

git merge --ff-only fix/recipe-config
git merge --ff-only fix/reactor-timing

git branch --delete test/combined-fix fix/recipe-config fix/reactor-timing
```

The same "integration branch" workflow can be used to develop new features and test in combination with other features and fixes.

### Keep Long Lived Feature Branches up to Date

Do this periodically on long-lived branches keeps the eventual merge conflict-free. The idea is that small frequent rebases are easier than one big one at the end.

```bash
git fetch origin
git checkout feature/branch
git rebase main
git push --force-with-lease origin feature/branch
```

### Clean up deleted branches

If you work on multiple devices, you may find branches that have been deleted on remote or other local system may still exist.

```bash
# Prune remote-tracking references (removes origin/feature/whatever for branches deleted on the remote):
git fetch --prune

# Delete local branches that no longer have a remote counterpart. This finds local branches whose upstream is marked [gone] (remote was deleted) and deletes them safely.
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d

# You can make pruning automatic on every fetch by setting. After that, git fetch and git pull will always clean up stale remote-tracking refs automatically.
git config --global fetch.prune true
```

## Topics

Git does not create an extra merge commit when merging a commit that is a descendant of the current commit. Instead, the tip of the current branch is fast-forwarded. This behavior can be modified (e.g., `--no-ff`) to force a merge commit. This is often desirable for clean history.

git rebase --onto is the tool for "I branched off the wrong place."

## Snippets

```bash
# Misc
git push --force-with-lease
# Resync origin/HEAD with remote default branch
git remote set-head origin --auto

# Visualize Branches
git log --oneline --graph --all --decorate
# What branches contain the fork point of <branch>?

git branch --contains $(git merge-base main <branch>)
```

```bash
# Show branches and likely parent
dst="main"
echo $dst
for branch in $(git branch --format='%(refname:short)'); do
  if [ "$branch" != "$dst" ]; then
    base=$(git merge-base "$dst" "$branch")
    ahead=$(git rev-list --count "$dst".."$branch")
    echo "$branch: $ahead commits ahead of $dst (forked at $(git log --oneline -1 $base))"
  fi
done
```

```bash
# Comparing branches
git diff --stat branch1 branch2
git diff branch1 branch2
```

## Questions

Say that my repo maintains a set of scripts or tools in addition to the main program code. If I make updates to these tools, how can I sync, access or propagate the new changes to other branches? In addition, what is the ideal strategy if I find this happening a lot or what is the problem?

## Next Topics

### git worktree

Instead of stashing/switching when you need to test another branch, worktrees let you have multiple branches checked out simultaneously in different directories. Great for your pattern of "develop on feature, test on integration branch."

### git bisect

Your test was passing last week, now it's failing. Bisect does a binary search across your commits to find the exact commit that introduced the regression.

### git stash (with -p and named stashes)

You've been working on a fix and suddenly need to test something on main branch. Stash pulls your uncommitted work aside temporarily. stash -p lets you stash only some changes. Pairs well with the throwaway integration branch pattern.

## Configuring Editors

```bash
# Sublime Text
echo 'export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"' >> ~/.zshrc
git config --global core.editor "subl -n -w"

## VS Code
git config --global core.editor "code --wait"
```
