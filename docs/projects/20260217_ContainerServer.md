# Container Server

- Dell Wyse 5070 (hereinafter "the server")
- Debian 13 (for stability)
- Headless
- Docker Compose

I haven't used vanilla Debian in ages and even then very little. I am most familiar with Arch and have some experience with Fedora, Red Hat and Ubuntu.

Debian is the "Base" for Ubuntu. [Debian touts itself](https://www.debian.org/intro/why_debian) as being mature, secure, reliable, stable, with long term support (five-year LTS).

Debian 13.3 was released on January 10th, 2026. Debian 13.0 was initially released on August 9th, 2025.  

## Install OS

I installed Debian 13 ("trixie") on the server using the "netinst" ISO. I maintain a [Ventoy](https://www.ventoy.net/en/index.html) USB drive, so it was a breeze to copy and paste the ISO and boot from local terminal.

I did not follow install instructions, the installer is very familiar. There is [plenty of literature](https://d-i.debian.org/manual/en.amd64/index.html) if needed. I used the traditional installer rather than graphical. I used the single disk defaults with following package selection.

- [ ] Desktop environment
- [ ] Webserver
- [X] SSH Server
- [X] Standard system utilities

After installation there is a "root" and a standard user account. I confirmed I could login from the terminal using the standard user and `su` to root. I then confirmed I could SSH into the standard user account from a remote system on the network.

```bash
ip --brief address
ssh <username>@<server_ip>
```

If all works as expected, can discard the crash cart (i.e., monitor and keyboard).

## Network Configuration

Add a static route to DHCP server then configure the server network interface with static IP. In this case, DHCP resides on the primary router.

Configuring the server with static IP will make it accessible in a deterministic and standalone way. This is particularly important when things go wrong or when trying to access the system outside the deployed environment.

```bash

```

## Client SSH Configuration

Repeat this section for each client needed.

```bash
# Create client key pair
ssh-keygen -t ed25519 -C "homelab" -f ~/.ssh/id_ed25519_homelab_<client_id>

# Copy client public key to server
ssh-copy-id -i ~/.ssh/id_ed25519_homelab_<client_id> <username>@<server_ip>

# Set client local permissions
chmod a-rwx,u+rwx .ssh/id_ed25519_homelab_<client_id>

# Test key authentication
ssh -i ~/.ssh/id_ed25519_homelab_<client_id> <username>@<server_ip>
```

See [GNU Coreutils manual for chmod](https://www.gnu.org/software/coreutils/manual/coreutils.html#Symbolic-Modes-1) for explanation of symbolic notation.

## Install Helper Packages

```bash
# Update package list (but don't upgrade)
apt update
apt list --upgradable --all-versions

apt sudo vim
```

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
- <https://www.debian.org/doc/manuals/debian-reference/index.en.html>

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

```bash
# For each client machine, create new SSH key
`ssh-keygen -t ed25519 -C "infra-homelab" -f C:\Users\<local_user>\.ssh\id_ed25519_homelab`

# Copy public key to the server
`ssh-copy-id -i /mnt/c/Users/<local_user>/.ssh/id_ed25519_homelab.pub <server_user>@<server_ip>`

# Verify key from server
`cat ~/.ssh/authorized_keys`
```

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
