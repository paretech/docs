# Container Server

The intent is to install headless Debian and Docker on an old Dell Wyse 5070 (hereinafter "server").

I haven't used base Debian much, I am most familiar with Arch. I have used plenty of others distributions like Fedora, Red Hat and Ubuntu in work context. Debian is the "Base" for Ubuntu and [touts itself](https://www.debian.org/intro/why_debian) as being mature, secure, reliable, and stable.

Debian 13.0 was initially released on August 9th, 2025. Debian 13.3 was released on January 10th, 2026. I'll be using the "stable" long term support (LTS) version which is supported for five-years.

For Docker, I'll be using the community edition (CE).

## Install Debian Linux

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

## Configure Network

Use the Debian install default DHCP network configuration for clean infrastructure. This means configuring a known IP address by adding config to router DHCP server.

Using this configuration method provides stable IP address, automatic DNS, automatic gateway, centralized network control. This makes our environment easier to rebuild without duplicating config.

Here are some common commands for doing various network related tasks.

```bash
# List network interfaces and MAC addresses
ip --brief link

# List IP addresses
ip --brief address

# List nameserver config
cat /etc/resolv.conf

# Test internet without DNS (Quad9)
ping -c3 9.9.9.9

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

## Configuration SSH Clients

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

## Harden SSH Access

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

# Double check config
grep -E '^[[:space:]]*(PermitRootLogin|PasswordAuthentication|KbdInteractiveAuthentication)[[:space:]]+' /etc/ssh/sshd_config
```

Evaluate changes. The following should not be possible. The only way that should be possible now is a standard user with SSH key pair.

- Attempt to login as standard user using name/password.
- Attempt to login as root using password
- Attempt to login as root using SSH key (would require setup)

## Check services and updates (run as needed)

Check to make sure no failing services or pending upgrades. Run this section as maintenance activity as needed.

- Do this to maintain existing packages and prior to installing new ones.
- Advanced Packaging Tool (APT)
- `dpkg` is the low-level package manager for Debian-base systems (install `.deb` files). `dpkg` is the engine underneath `apt`.
- List of package sources `/etc/apt/sources.list`
  - "main" fully comply with Debian Free Software Guidelines
  - "non-free" not (entirely) conform to guidelines
  - "contrib" OSS but cannot function without some "non-free" (section or external) elements

```bash
# Check for failed services (expect 0)
systemctl --failed

# Confirm only expected services are running
systemctl list-units --type=service --state=running

# Check pending upgrades
sudo apt update
sudo apt list --upgradable

# Apply upgrades and remove installed packages (if required)
sudo apt full-upgrade

# Check unnecessary packages (expect 0)
sudo apt autoremove --dry-run
```

In the event it is needed, here are some common `dpkg` operations.

```bash
# List installed packages 
dpkg --list

# Which package owns a file
dpkg --search <file_path>

# List files installed by a package
dpkg --listfiles <package_name>
```

The base OS layer is now complete! On to the next phase...

## Install and Configure Docker

When standing up the system, you have the choice. Use Debian docker or use the official upstream community edition (CE) repo.

`docker-ce` is provided by docker.com, `docker.io` is provided by Debian.

Docker IO is conservative and stable. Docker CE may have newer features and better compose integration. Unless there is a strong reason to use the Debian version, general recommendation is to use Docker CE.

The remainder of this document assumes Docker CE.

If you are curious about what else is evolving in this space, checkout `Podman` from Red Hat. It just didn't make sense for me at this time.

Docker engine comes bundled with Docker Desktop for Linux but it is not designed for headless server nodes. It is a developer tool that introduces complexity.

Some resources

- <https://stackoverflow.com/questions/45023363/what-is-docker-io-in-relation-to-docker-ce-and-docker-ee-now-called-mirantis-k>
- <https://docs.docker.com/engine/install/debian/>
- <https://docs.docker.com/engine/install/debian/#install-using-the-repository>
- <https://docs.docker.com/engine/install/linux-postinstall>
- <https://docs.docker.com/get-started/workshop/>

These instructions are more or less verbatim from [dockerdocs](https://docs.docker.com/engine/install/debian/#install-using-the-repository).

```bash
# Remove conflicting packages (not likely). Apt will likely report you have none of these installed.
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# Add Docker GPG Key
sudo apt update
sudo apt install ca-certificates curl
# Why 755 permissions?
sudo install -m 0755 -d /etc/apt/keyrings
# Why gpg instead of asc?
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker Repo to Apt Sources
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install Docker packages
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker service starts automatically after install. Verify it is running.
sudo systemctl status docker

# Docker can be manually started
sudo systemctl start docker

# Verify successful install by running hello-world image
sudo docker run hello-world

# Display Docker info
sudo docker info
```

## Building the Service Stack

Goals:

- Reverse Proxy (Caddy)
  - Single entry point with name-based routing
  - TLS
  - Centralized auth (Authelia)
-  

## Create File Structure

For now all the infrastructure services are created under "/srv". As this node gets populated, you might consider adding a second level for "infra", "apps", "experiments", "backups", etc... Since there is not a use case or implementation for those additional layers at this time, I'm simply using "/srv".

To make this change easy later,

- Run compose from the service directory (i.e., location of compose.yml)
- Use relative bind mounts instead of absolute paths in compose files

The point is, directory moves in Docker setups should be inexpensive and easy to move around. If not, that is a smell.

```bash
    #!/usr/bin/env bash
    set -e

    BASE_DIR="/srv"

    declare -a SERVICE_NAMES=("caddy" "portainer" "homeassistant")
    declare -a BASE_FILES=("compose.yml")
    declare -a BASE_DIRS=("data" "config")

    echo "Creating base directory: $BASE_DIR"
    mkdir -p "$BASE_DIR"

    # Create service file structure
    for service in "${SERVICE_NAMES[@]}"; do
        service_path="$BASE_DIR/$service"

        echo "Setting up service: $service"
        mkdir -p "$service_path"

        # Create base files
        for file in "${BASE_FILES[@]}"; do
            file_path="$service_path/$file"
            if [ ! -f "$file_path" ]; then
                touch "$file_path"
                echo "  Created file: $file_path"
            else
                echo "  File exists: $file_path"
            fi
        done

        # Create base directories
        for dir in "${BASE_DIRS[@]}"; do
            dir_path="$service_path/$dir"
            mkdir -p "$dir_path"
            echo "  Ensured directory: $dir_path"
        done
    done

    echo "Done!"
```

```bash
    BASE_DIR="/srv"
    service="caddy"
    SERVICE_DIR="$BASE_DIR/$service"

    # Brace expansion happens before variable expansion, not inside quotes
    sudo mkdir -p "$SERVICE_DIR"/{data,config}
    sudo touch "$SERVICE_DIR"/{compose.yml,Caddyfile}
```

## Create Docker Network

- <https://docs.docker.com/engine/network/>
  - "Container networking refers to the ability for containers to connect to and communicate with each other, and with non-Docker network services."
  - "With the default configuration, containers attached to the default bridge network have unrestricted network access to each other using container IP addresses. They cannot refer to each other by name."
  - "You can create custom, user-defined networks, and connect groups of containers to the same network. Once connected to a user-defined network, containers can communicate with each other using container IP addresses or container names."
  - "Connecting a container to a network can be compared to connecting an Ethernet cable to a physical host."

- <https://docs.docker.com/engine/network/drivers/bridge/>
  - "Allows unrestricted network access to containers in the network from the host, and from other containers connected to the same bridge network."
  - "By default, the Docker bridge driver automatically installs rules in the host machine so that containers connected to different bridge networks can only communicate with each other using published ports."
  - "When you start Docker, a default bridge network (also called bridge) is created automatically, and newly-started containers connect to it unless otherwise specified." "This can be a risk, as unrelated stacks/services/containers are then able to communicate."
  - "User-defined bridge networks are superior to the default bridge network."
  - "User-defined bridges provide automatic DNS resolution between containers."
- <https://docs.docker.com/reference/cli/docker/network/>

```bash
    docker network create proxy
    docker network ls
    docker network inspect proxy
```

## Compose Caddy

Create file structure

```bash
    SERVICE="caddy"
    BASE_DIR="/srv"
    SERVICE_DIR="$BASE_DIR/$SERVICE"

    # Brace expansion happens before variable expansion, not inside quotes
    sudo mkdir -p "$SERVICE_DIR"/{conf,data,state}
    sudo touch "$SERVICE_DIR"/{compose.yml,}
    sudo touch "$SERVICE_DIR/conf"/{caddyfile,}
```

Create Docker network

```bash
    docker network create proxy
    docker network ls
    docker network inspect proxy
```

<https://caddyserver.com/docs/running#docker-compose>

Populate compose.yml. Our volumes are defined a bit different than the Caddy documentation. Our intent is to have light weight easy to review and rebuild which means the files are within our /srv directory and not embedded in the container.

```yml
    services:
    caddy:
        image: caddy:2
        container_name: caddy
        restart: unless-stopped

        # Only Caddy publishes ports to the host.
        # All other services remain internal to the proxy network.
        ports:
        - "80:80"
        - "443:443"

        networks:
        - proxy

        volumes:
        # Our declarative Caddy configuration
        - ./conf:/etc/caddy

        # TLS certificates, ACME account data, internal CA
        - ./data:/data

        # Caddy runtime metadata/state (not manually edited)
        - ./state:/config

    networks:
    proxy:
        # Pre-created user-defined bridge network
        external: true
```

```bash
# Inspect service config and file structure
cd /srv/caddy
ls -la

# Start Caddy
docker compose up --detach

# Verify running
docker ps

# Check logs
docker logs --follow caddy
docker logs --tail=100 caddy

# Make changes to compose.yaml and restart
docker compose restart

# Tear down (only if needed)
docker compose down
docker compose up --detach

# Make changes to Caddyfile and reload
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# inspect port binding
ss -tulpn

# Inspect docker network
docker network inspect proxy --format '{{json .Containers}}' | jq .

# Confirm only caddy is exposing ports
docker ps --format 'table {{.Names}}\t{{.Ports}}'

# Fetch output
curl -v http://127.0.0.1/

# Try opening from browser on a computer on the network!
```

## Next Steps

- Verify time sync
- File structure
- Docker network
- Install Caddy
- Local DNS
- Portainer
- Home assistant

## Other Topics

- Forward DNS resolves name to IP address
- Reverse DNS resolves IP to name (mostly cosmetic)
- Forward Proxy
- Reverse Proxy
- Docker Community Edition (CE)
- Docker Enterprise Edition (EE)
- Podman
- Portainer
- Borg
- Restic
