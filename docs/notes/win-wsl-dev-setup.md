# Windows + WSL Setup

This document captures a **low-friction, reproducible Windows development setup** using:

- Windows as the primary desktop
- WSL2 (Ubuntu) as the Linux dev environment
- VS Code as the editor
- Git over HTTPS using Windows Git Credential Manager (GCM)

The goal is:

- A workflow that feels the same on **Windows / WSL / Linux / macOS**
- Minimal credential sprawl
- Easy “nuke and pave” recovery
- Boring, predictable behavior

This intentionally documents **only the happy path**. Alternatives are mentioned briefly at the end.

---

## Mental Model

- Windows = desktop + auth + credential storage
- WSL = disposable Linux dev appliance
- VS Code = UI shell attached to WSL
- Git auth = handled once, centrally, by Windows

If WSL ever feels weird → **delete it and recreate it**.

---

## 1. Windows Prerequisites

### Enable / install WSL2

From **PowerShell (Admin)**:

```powershell
wsl --install
```

Reboot if prompted.

Verify:

```powershell
wsl --status
wsl --list --verbose
```

---

## 2. Install or Refresh Ubuntu in WSL (Nuke & Pave)

If you don’t care about preserving the old environment (recommended):

```powershell
wsl --list --verbose
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

First launch will prompt you to create a Linux user.

Verify inside WSL:

```bash
lsb_release -a
python3 --version
```

Expected:

- Ubuntu 22.04 or 24.04
- Python ≥ 3.10

---

## 3. Ubuntu Hygiene (First Boot)

Immediately after installing Ubuntu:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
```

This is **normal** and expected. The image is a snapshot, not fully patched.

### Base packages

```bash
sudo apt install -y \
  build-essential \
  make \
  git \
  python3 \
  python3-venv \
  python3-pip \
  curl \
  unzip
```

Ongoing cadence:

```bash
sudo apt update && sudo apt full-upgrade
```

---

## 4. Update Git for Windows (Critical)

Windows Git and WSL Git are **separate**, but can share credentials.

### Update Windows Git

From **Git Bash**:

```bash
git update-git-for-windows
```

This safely removes old versions and installs the latest one.

Verify (PowerShell or Git Bash):

```bash
git --version
git credential-manager --version
```

Expected:

- Git 2.4x+
- GCM 2.x+

---

## 5. Install Git in WSL

Inside Ubuntu:

```bash
sudo apt install git
git --version
```

This is normal and required — WSL uses Linux Git binaries.

---

## 6. Configure Git Identity (WSL)

Inside WSL:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

---

## 7. Git Authentication (HTTPS via Windows GCM)

This setup uses **HTTPS**, not SSH.

### Why HTTPS + GCM

- One sign-in per service
- Tokens stored in Windows Credential Manager
- No SSH agents, no key copying
- Survives WSL rebuilds

### Point WSL Git at Windows GCM

Inside WSL:

```bash
git config --global credential.helper \
"/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
```

Verify:

```bash
git config --global --get credential.helper
```

---

## 8. Test Git Authentication

Trigger a test over HTTPS:

```bash
git ls-remote https://github.com/git/git >/dev/null
```

First time:

- Browser opens for sign-in
- Token stored in Windows Credential Manager

Subsequent operations:

- Silent

---

## 9. Cloning Repositories (WSL)

Always clone **inside WSL**, into the Linux filesystem:

```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/org/repo.git
```

Avoid `/mnt/c/...` for active development repos.

---

## 10. VS Code Integration (Recommended)

Install VS Code extension:

- **Remote – WSL**

From WSL:

```bash
cd ~/projects/repo
code .
```

VS Code will:

- Run its server inside WSL
- Use Linux tools, paths, and Python
- Avoid Windows/WSL confusion

---

## 11. Using Windows Editors from WSL

WSL can run Windows executables directly, allowing you to open files in Windows editors from the Linux command line.

### Sublime Text Example

Create a symbolic link to the Windows executable:

```bash
sudo ln -s "/mnt/c/Program Files/Sublime Text 3/subl.exe" /usr/local/bin/subl
```

This creates a persistent link in `/usr/local/bin/`, which is already in your `$PATH`.

Now you can open files from WSL:

```bash
subl install.sh
subl ~/projects/repo/
```

### Why This Works

- WSL has interoperability with Windows executables (`.exe` files)
- Windows programs are accessible via `/mnt/c/`
- `/usr/local/bin/` is the standard location for locally installed executables
- The symlink persists across reboots—it's a permanent file in the filesystem

### Other Editors

The same pattern works for any Windows editor with a CLI:

```bash
# Notepad++
sudo ln -s "/mnt/c/Program Files/Notepad++/notepad++.exe" /usr/local/bin/npp

# Generic pattern
sudo ln -s "/mnt/c/path/to/editor.exe" /usr/local/bin/editor-name
```

### Verifying the Path

If the symlink doesn't work, verify the Windows path exists:

```bash
ls "/mnt/c/Program Files/Sublime Text 3/"
```

---

## 12. Setting Up ZSH (Optional)

Ubuntu defaults to Bash, but ZSH offers better autocompletion, history, and plugin support.

### Install ZSH

```bash
sudo apt install -y zsh
```

### Set ZSH as Default Shell

```bash
chsh -s $(which zsh)
```

Log out and back in (close and reopen the terminal) for this to take effect.

### Install Oh My Zsh (Recommended)

Oh My Zsh provides sensible defaults, themes, and plugin management:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

This will:

- Install to `~/.oh-my-zsh/`
- Create `~/.zshrc` with defaults
- Set the `robbyrussell` theme

### Minimal Configuration

Edit `~/.zshrc` to enable useful plugins:

```bash
plugins=(git z)
```

- **git** — Adds aliases and completion for Git commands
- **z** — Jump to frequently used directories (e.g., `z proj` → `~/projects`)

### Why ZSH

- Better tab completion (case-insensitive, partial matching)
- Shared history across sessions
- Syntax highlighting (with plugin)
- Large ecosystem of themes and plugins

### Keeping It Minimal

In the spirit of "nuke and pave", avoid over-customizing. Stick to:

- Default Oh My Zsh theme
- 2-3 plugins max
- No custom scripts that would be painful to recreate

---

## 13. Operating Philosophy

- Treat WSL as **disposable**
- Keep projects in git
- Keep global state minimal
- Rebuild instead of debugging “mystery drift”

This matches modern cloud/CI mental models and keeps friction low.

---

## 14. Alternatives (Not Documented Here)

These are valid, but intentionally not part of the happy path:

- SSH-based Git auth (keys + agents)
- Separate GCM installation inside WSL
- Per-project Python version managers (pyenv)
- Dockerized dev environments

Only reach for these if you have a concrete need.

---

## Summary

This setup gives you:

- Unified Git auth across Windows + WSL
- Clean Linux tooling
- Minimal secrets management
- Easy recovery
- A workflow that closely mirrors macOS/Linux

If something feels broken, **delete Ubuntu and recreate it** — that’s a feature, not a failure.
