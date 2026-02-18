# Container Server

- Dell Wyse 5070 (hereinafter "server")
- Debian 13 (for stability)
- Headless
- Docker Compose

## Phase 1 - Install OS

- Installed Debian 13 ("trixie") from Ventoy deployed "net" ISO
- Debian 13.3 was released on January 10th, 2026. Debian 13.0 was initially released on August 9th, 2025.  

I haven't used vanilla Debian in ages. Here is how Chat GPT frames it within the context of environments I'm more familiar with (i.e., Arch, Fedora, Ubuntu, Red Hat).

- Philosophy: Ultra-stable, conservative, community-driven; “boring in a good way.”
- Release cadence: Slow, predictable; Stable branch prioritized over newest packages.
- Branches: stable (prod), testing (next stable), unstable/sid (rolling dev).
- Packages: Older but well-patched; huge repo; strong dependency hygiene.
- Init/system: systemd by default (like Ubuntu/Fedora/RHEL now).
- Package tools: apt/dpkg (same core as Ubuntu, but less Canonical tooling).
- Defaults: Minimal, no branding/opinionated UX; you assemble what you need.
- Security model: Very cautious updates; separate security repo; long support.
- Free software stance: Strict separation of main, contrib, non-free.
- Relation to others:
- Ubuntu = Debian + faster releases + Canonical polish.
- RHEL/Fedora = more enterprise/bleeding-edge vs Debian stability.
- Best use cases: Servers, appliances, containers, long-lived infra.
- Mental model: Arch control + Ubuntu tooling − churn − corporate layer = Debian.

## Phase 2 - Make it Headless

Goal

- SSH access from your main workstation
- Key-based authentication
- Safe to unplug monitor/keyboard
- Deterministic network identity

Exit when computer is a remotely managed appliance node.

Resources

- <https://www.debian.org/releases/forky/amd64/index.en.html>
- <https://www.debian.org/doc/ddp>
- <https://www.debian.org/doc/user-manuals>
- <https://www.debian.org/doc/manuals/debian-handbook/index.en.html>

### Maintaining Packages

- Do this to maintain existing packages and prior to installing new ones.
- Advanced Packaging Tool (APT)
- List of package sources `/etc/apt/sources.list`
  - "main" fully comply with Debrian Free Software Guidelines
  - "non-free" not (entirely) conform to guidlines
  - "contrib" OSS but cannot function without some "non-free" (section or external) elements

```sh
apt update
apt list --upgradable --all-versions

```

### Install Packages

### 2A — Network Identity

- Assigned static IP address for server at router by binding MAC address to `<server_ip>`.

### 2B SSH Access and Hardening

- From desktop, create new SSH key
  - `ssh-keygen -t ed25519 -C "infra-homelab" -f C:\Users\<local_user>\.ssh\id_ed25519_homelab`
- Copy public key to the server
  - `ssh-copy-id -i /mnt/c/Users/<local_user>/.ssh/id_ed25519_homelab.pub <server_user>@<server_ip>`
- Verify key from server
  - `cat ~/.ssh/authorized_keys`

Known IP address

Known hostname

Reliable DNS resolution

Verified internet connectivity

Success criteria:

You can ping it from another machine

You can reach Debian package mirrors

Reboot does not change identity

This is the foundation for everything else.

2B — SSH Reachability

Because you selected SSH server during install, now confirm:

Success criteria:

You can SSH from your laptop/desktop

Login works using password first (temporary)

Latency/connection stable across reboots

This is the first true infrastructure control plane.

2C — Key-Based Authentication & Lockdown

Next we transition to real server posture:

Target state:

SSH key-only login

Password login disabled

Root remote login disabled

Non-root sudo user used for admin

When done:

The node is safe to leave powered on permanently.

2D — Update & Reboot Confidence

Before installing Docker, confirm OS health:

Success criteria:

Fully updated packages

Clean reboot

SSH comes back automatically

Time sync correct

No boot errors

This ensures Docker problems later aren’t actually OS problems.

Gate 2 — Headless Infrastructure Node

You pass Gate 2 when:

You can manage the Wyse entirely over SSH

Reboot requires no physical interaction

System identity is stable and known

Console can be unplugged and forgotten

At that moment, psychologically:

The machine stops being a “PC”
and becomes infrastructure

#### Outstanding Items

- How to reduce friction between windows powershell and WSL instances? I've been trying to use WSL shell as my primary environment.
- Set server local IP to DHCP IP reservation. This way you can still get into the system even if you don't have a DHCP server or you ar trying to access outside of network. Several other reasons why this is a good idea...
- Install SUDO command
