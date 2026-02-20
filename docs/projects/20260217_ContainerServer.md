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

Additional Debian resources

- <https://www.debian.org/releases/forky/amd64/index.en.html>
- <https://www.debian.org/doc/ddp>
- <https://www.debian.org/doc/user-manuals>
- <https://www.debian.org/doc/manuals/debian-handbook/index.en.html>
- <https://www.debian.org/doc/manuals/debian-reference/index.en.html>

## Network Configuration

Use the Debian install default DHCP network configuration for clean infrastructure. This means configuring a known IP address by adding config to router DHCP server.

Using this configuration method provides stable IP address, automatic DNS, automatic gateway, centralized network control. This makes our environment easier to rebuild without duplicating config.

Here are some common commands for doing various network related tasks.

```bash
# List network interfaces and MAC addresses
ip --brief link

# List IP addresses
ip --brief address

# Test internet without DNS (Cloudflare DNS IP)
ping -c3 1.1.1.1

# Test internet with DNS
ping -c3 google.com

# Restart network service
sudo systemctl restart networking

# Stop an interface
if down <interface>

# Start an interface
if up <interface>
```

For additional information on network configuration, see `/etc/network/interfaces` and `man interfaces` for additional documentation of this file.

See also [Debian Reference](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html) and [Debian Wiki](https://wiki.debian.org/NetworkConfiguration?utm_source=chatgpt.com).

If you can ping internet resources with and without DNS services, then network config is likely good and you can discard the crash cart (i.e., monitor and keyboard) and switch to SSH.

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

See [Debian manpages of openssh-client](https://manpages.debian.org/stretch/openssh-client/index.html) for additional context of these commands.

See [GNU Coreutils manual for chmod](https://www.gnu.org/software/coreutils/manual/coreutils.html#Symbolic-Modes-1) for explanation of symbolic notation.

You can optionally define an [SSH client config](https://man.openbsd.org/ssh_config). This can be convenient for simplified user experience (e.g., `ssh <short_name>`).

```config
Host <short_name>
    HostName <host_ip>
    User <user_name>
    IdentityFile <id_file>
```

Now you can connect from your client machine by simply executing `ssh short_name`!

See also [OpenSSH Manual Pages](https://www.openssh.org/manual.html).

## Install and Configure Sudo

Install Sudo. Sudo includes the visudo subcommand.

```sh
apt update
apt install sudo
```

Add user to sudo group

```sh
# check which groups <user_name> is already a member of
groups <user_name>

# add user to sudo group
usermod --append --groups sudo <user_name>

# verify new groups
groups <user_name>
```

After adding user to group. Close all SSH sessions and verify.

```sh
# Expect <user_name>
whoami

# Expect root
sudo whoami
```

Sudo `/etc/sudoers` is now configured such that any user belonging to the `sudo` group may execute any command as any user. Modifications to the sudoers config should be made with `visudo`. `visudo` is installed as part of the `sudo` package.

See `man sudo` and [Sudo Manual](https://www.sudo.ws/docs/man/sudoers.man/) for additional documentation.

## Disable root SSH access

Edit `/etc/ssh/sshd_config`.

```bash
# Disable SSH password authentication for all users
PasswordAuthentication no

# Disable root SSH login
PermitRootLogin no

# Disable keyboard interactive authentication for all users
# Note: ChallengeResponseAuthentication is a deprecated alias for KbdInteractiveAuthentication
KbdInteractiveAuthentication no
```

!!! warning "Do not close your current SSH session"
Do not close your current SSH session. You must verify a new login works first or you could lock yourself out.

```bash
# Restart SSH service
sudo systemctl restart ssh

# Get service status
sudo systemctl status ssh

# Inspect systemd log entries for errors, should have similar output as systemctl status
sudo journalctl --unit ssh --lines 50 --no-pager
```

Evaluate changes. The following should not be possible. The only way that should be possible now is a standard user with SSH key pair.

- Attempt to login as standard user using name/password.
- Attempt to login as root using password
- Attempt to login as root using SSH key (would require setup)

## Disable root terminal login

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

## Lock Down Login

## Next Steps

Reliable DNS resolution

Before installing Docker, confirm OS health:

Success criteria:

## Fully updated packages

- Do this to maintain existing packages and prior to installing new ones.
- Advanced Packaging Tool (APT)
- List of package sources `/etc/apt/sources.list`
  - "main" fully comply with Debrian Free Software Guidelines
  - "non-free" not (entirely) conform to guidlines
  - "contrib" OSS but cannot function without some "non-free" (section or external) elements

```bash
sudo apt update

```

## More Next Steps

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

## Outstanding Items

- How to reduce friction between windows powershell and WSL instances? I've been trying to use WSL shell as my primary environment.
- Set server local IP to DHCP IP reservation. This way you can still get into the system even if you don't have a DHCP server or you ar trying to access outside of network. Several other reasons why this is a good idea...
- Install SUDO command
