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

## 11. Operating Philosophy

- Treat WSL as **disposable**
- Keep projects in git
- Keep global state minimal
- Rebuild instead of debugging “mystery drift”

This matches modern cloud/CI mental models and keeps friction low.

---

## 12. Alternatives (Not Documented Here)

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
