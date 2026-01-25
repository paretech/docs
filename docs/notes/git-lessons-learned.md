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

## Git (WSL) + Windows Credential Manager: Helper Path with Spaces

### Problem

Using **Git Credential Manager for Windows (GCM)** from **WSL Git** failed when the helper path contained a space (`Program Files`). Git either:

- tried to execute `/mnt/c/Program` as a command, or
- treated the helper as `git-credential-<name>` instead of an executable path.

This only surfaced when cloning or accessing **private repos** (i.e., when auth was actually required).

### Symptoms

- Errors like:
  - `/mnt/c/Program: not found`
  - `git: 'credential-/mnt/c/Program Files/...' is not a git command`
- Public repos cloned fine; private repos failed
- Git prompted for username/password (which GitHub no longer supports)
- `git credential-manager --version` did not work in WSL (expected)

### Root Cause

`credential.helper` was configured with a path containing spaces, but Git parsed it incorrectly unless the space was **escaped in the stored gitconfig value**. Shell quoting alone was not sufficient.

### Fix (WSL)

Unset all helpers, then store the helper path with an **escaped space**:

```bash
git config --global --unset-all credential.helper
git config --global credential.helper '/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe'
```

Then retrigger auth with any HTTPS Git operation and complete the browser/device login flow.

### Helpful Checks

Helpful Checks

Verify exactly one helper is configured:

```bash
git config --global --show-origin --get-all credential.helper
```

Test auth silently:

```bash
git ls-remote <https://github.com/><user>/<private-repo>.git >/dev/null
```

Confirm the helper binary exists:

```bash
ls "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
```

### Notes

This setup reuses Windows Credential Manager; WSL has no local credential cache.

git credential-manager ... is not a valid command in WSL unless Linux GCM is installed.

Public repos can mask helper misconfiguration because no auth is required.
