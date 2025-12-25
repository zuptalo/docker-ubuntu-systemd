# Examples

This directory contains example Ansible playbooks and configurations to demonstrate how to use the Ubuntu systemd container.

## Quick Start

### Using Docker Compose with Pre-built Image

The easiest way to get started is using the pre-built image from GitHub Container Registry:

```bash
# Set your GitHub repository (or use the default)
export GITHUB_REPOSITORY="zuptalo/docker-ubuntu-systemd"

# Start the containers and run the example playbook
docker compose up

# Or run in detached mode
docker compose up -d
```

### Manual Testing with Ansible

If you prefer to run Ansible from your local machine:

```bash
# Start just the Ubuntu container
docker compose up -d ubuntu-test

# Wait a few seconds for SSH to start
sleep 5

# Test connectivity
ansible all -i inventory.yml -m ping

# Run any of the example playbooks
ansible-playbook -i inventory.yml playbooks/nginx-setup.yml
ansible-playbook -i inventory.yml playbooks/docker-install.yml
ansible-playbook -i inventory.yml playbooks/user-management.yml
ansible-playbook -i inventory.yml playbooks/systemd-service.yml
ansible-playbook -i inventory.yml playbooks/security-hardening.yml
```

## Available Playbooks

### 1. nginx-setup.yml
Installs and configures Nginx web server with a custom index page.

**Use case**: Testing web server deployment and systemd service management.

```bash
ansible-playbook -i inventory.yml playbooks/nginx-setup.yml
```

### 2. docker-install.yml
Installs Docker Engine and Docker Compose on the Ubuntu container.

**Use case**: Testing Docker installation procedures and repository configuration.

```bash
ansible-playbook -i inventory.yml playbooks/docker-install.yml
```

### 3. user-management.yml
Creates users, groups, and manages permissions.

**Use case**: Testing user provisioning and access control.

```bash
ansible-playbook -i inventory.yml playbooks/user-management.yml
```

### 4. systemd-service.yml
Creates a custom systemd service and timer.

**Use case**: Testing systemd service creation, management, and timers.

```bash
ansible-playbook -i inventory.yml playbooks/systemd-service.yml
```

### 5. security-hardening.yml
Applies basic security hardening including SSH configuration, fail2ban, and automatic updates.

**Use case**: Testing security compliance and hardening procedures.

```bash
ansible-playbook -i inventory.yml playbooks/security-hardening.yml
```

## Inventory Configuration

The `inventory.yml` file is pre-configured to connect to the container:

```yaml
all:
  children:
    test_servers:
      hosts:
        ubuntu-test:
          ansible_host: localhost
          ansible_port: 2222
          ansible_user: ubuntu
          ansible_password: ubuntu
```

## SSH Access

You can SSH directly into the container for debugging:

```bash
ssh ubuntu@localhost -p 2222
# Password: ubuntu
```

Or as root:

```bash
ssh root@localhost -p 2222
# Password: root
```

## Customization

### Modifying Playbooks

Feel free to modify any playbook to test your specific use cases. All playbooks use best practices:
- Idempotent tasks
- Proper error handling
- Use of systemd module for service management
- Appropriate use of `become` for privilege escalation

### Adding Your Own Playbooks

Create new playbooks in the `playbooks/` directory and run them the same way:

```bash
ansible-playbook -i inventory.yml playbooks/your-playbook.yml
```

## Multi-Container Testing

To test against multiple containers, modify `compose.yaml` to add more Ubuntu instances:

```yaml
ubuntu-test-2:
  image: ghcr.io/${GITHUB_REPOSITORY}:latest
  container_name: ubuntu-ansible-test-2
  hostname: ubuntu-test-2
  privileged: true
  tmpfs:
    - /tmp:exec
    - /run
    - /run/lock
  ports:
    - "2223:22"
  networks:
    - ansible-test
```

Then update `inventory.yml`:

```yaml
all:
  children:
    test_servers:
      hosts:
        ubuntu-test-1:
          ansible_host: localhost
          ansible_port: 2222
          ansible_user: ubuntu
          ansible_password: ubuntu
        ubuntu-test-2:
          ansible_host: localhost
          ansible_port: 2223
          ansible_user: ubuntu
          ansible_password: ubuntu
```

## Cleanup

```bash
# Stop and remove containers
docker compose down

# Remove all data
docker compose down -v
```
