# Git Lessons Learned

> This note captures git workflows and techniques learned over time.

## Moving Commits to a New Branch After the Fact

### The Problem

You made commits directly on `main` but realize you should have created a feature branch first. This is common when you start working and forget to branch, or when you want to use a PR workflow even as a solo developer.

### The Solution

```bash
# 1. Create a new branch pointing to your current commit (preserves your work)
git branch feature-branch-name

# 2. Reset main back to match origin/main
git reset --hard origin/main

# 3. Switch to your feature branch
git checkout feature-branch-name

# 4. Push the feature branch to origin and set up tracking
git push -u origin feature-branch-name

# 5. Create a pull request
gh pr create --title "Your PR title" --body "Description of changes"
```

### What Each Command Does

| Command | Purpose |
|---------|---------|
| `git branch <name>` | Creates a new branch at your current HEAD without switching to it |
| `git reset --hard origin/main` | Moves `main` pointer back to match remote; safe because your work exists on the new branch |
| `git checkout <name>` | Switches to the specified branch |
| `git push -u origin <name>` | Pushes branch to remote; `-u` sets up tracking for future pushes |
| `gh pr create` | Creates a pull request from your current branch to the default branch |

### Why Use This Workflow

Even for solo projects, using feature branches and PRs provides:

- A cleaner commit history with meaningful merge points
- Practice with collaborative workflows
- The ability to review your own changes before merging
- Easy rollback if something goes wrong
