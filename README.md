# Ubuntu Systemd Docker Container

A systemd-enabled Ubuntu Docker container designed as a drop-in replacement for testing Ansible playbooks before deploying to actual Ubuntu VMs or servers. Perfect for local development, CI/CD pipelines, and testing infrastructure-as-code without requiring virtual machines.

[![Build and Publish](https://github.com/zuptalo/docker-ubuntu-systemd/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/zuptalo/docker-ubuntu-systemd/actions/workflows/docker-publish.yml)
[![Docker Image Version](https://img.shields.io/github/v/tag/zuptalo/docker-ubuntu-systemd?label=version)](https://github.com/zuptalo/docker-ubuntu-systemd/tags)
[![Docker Image Size](https://ghcr-badge.egpl.dev/zuptalo/docker-ubuntu-systemd/size?tag=latest)](https://github.com/zuptalo/docker-ubuntu-systemd/pkgs/container/docker-ubuntu-systemd)
[![License](https://img.shields.io/github/license/zuptalo/docker-ubuntu-systemd)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/zuptalo/docker-ubuntu-systemd?style=social)](https://github.com/zuptalo/docker-ubuntu-systemd/stargazers)

**[📦 View on GitHub Packages](https://github.com/zuptalo/docker-ubuntu-systemd/pkgs/container/docker-ubuntu-systemd)** | **[🐛 Report Issues](https://github.com/zuptalo/docker-ubuntu-systemd/issues)** | **[⭐ Star this repo](https://github.com/zuptalo/docker-ubuntu-systemd)**

---

## 🎯 Why This Container?

- 🔧 **Full systemd support**: Test service management, timers, and other systemd features
- 🤖 **Ansible-ready**: Pre-configured for seamless Ansible testing
- ⚡ **Fast and lightweight**: Faster than VMs, more realistic than minimal containers
- 🔄 **CI/CD friendly**: Perfect for automated testing pipelines
- 🏗️ **Multi-architecture**: Supports both AMD64 and ARM64
- 📦 **Pre-built images**: Available on GitHub Container Registry

## ✨ Features

- ✅ Full systemd support with properly configured init system
- ✅ SSH server enabled and configured
- ✅ Pre-installed essential server packages
- ✅ Python3 for Ansible compatibility
- ✅ Default ubuntu user with sudo privileges (like standard Ubuntu installations)
- ✅ Root access enabled for testing
- ✅ Common networking tools included
- ✅ Automatic builds with GitHub Actions
- ✅ Multi-platform support (linux/amd64, linux/arm64)

---

## 🚀 Quick Start

### ⚡ Recommended: Use Pre-built Image (Fastest)

Perfect for trying it out or using in your projects:

```bash
# Using the quick start script
./run.sh prod

# Or using Make
make prod

# Or using Docker Compose directly
docker compose -f compose.yaml up -d
```

### 🔧 Development: Build from Source

For contributing or customizing the image:

```bash
# Using the quick start script
./run.sh dev

# Or using Make
make dev

# Or using Docker Compose directly
docker compose -f compose.dev.yml up -d
```

### 📝 Common Commands

```bash
# Quick start with pre-built image
./run.sh prod

# Development mode (build from source)
./run.sh dev

# Test with Ansible
./run.sh test

# Run example playbooks
./run.sh test-nginx
./run.sh test-systemd

# SSH into the container
./run.sh ssh

# View all available commands
./run.sh help
```

### Manual Docker Commands

**Using pre-built image:**
```bash
docker pull ghcr.io/zuptalo/docker-ubuntu-systemd:latest

docker run -d \
  --name ubuntu-systemd-test \
  --privileged \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs /run/lock \
  -p 2222:22 \
  ghcr.io/zuptalo/docker-ubuntu-systemd:latest
```

**Building from source:**
```bash
docker build -t docker-ubuntu-systemd .

docker run -d \
  --name ubuntu-systemd-test \
  --privileged \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs /run/lock \
  -p 2222:22 \
  docker-ubuntu-systemd
```

---

## 🧪 Testing with Ansible

### SSH Connection

The container exposes SSH on port 2222 (mapped from container's port 22).

**Available credentials:**
- User: `ubuntu` / Password: `ubuntu` (with sudo privileges)
- User: `root` / Password: `root`

```bash
# Test SSH connection
ssh ubuntu@localhost -p 2222
# or
ssh root@localhost -p 2222
```

### Ansible Inventory Example

Create an inventory file `inventory.ini`:

```ini
[test_servers]
ubuntu-test ansible_host=localhost ansible_port=2222 ansible_user=ubuntu ansible_password=ubuntu

[test_servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
```

Or use `inventory.yml`:

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
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
```

### Run Ansible Playbook

```bash
# Ping test
ansible all -i inventory.ini -m ping

# Run a playbook
ansible-playbook -i inventory.ini your-playbook.yml
```

### Example Playbook

```yaml
---
- name: Test playbook
  hosts: test_servers
  become: yes
  tasks:
    - name: Ensure nginx is installed
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Ensure nginx is running
      systemd:
        name: nginx
        state: started
        enabled: yes

    - name: Check systemd status
      command: systemctl status nginx
      register: nginx_status

    - name: Display nginx status
      debug:
        var: nginx_status.stdout_lines
```

---

## ⚙️ systemd Features

The container runs a full systemd init system, allowing you to:

- Start/stop/restart services with `systemctl`
- Enable/disable services for boot
- Check service status and logs with `journalctl`
- Test service configurations
- Use timers and other systemd units

### Accessing the Container

```bash
# Execute commands in the container
docker exec -it ubuntu-systemd-test bash

# Check systemd status
docker exec ubuntu-systemd-test systemctl status

# View running services
docker exec ubuntu-systemd-test systemctl list-units --type=service
```

---

## 🔀 Multi-Host Testing

Uncomment the `ubuntu-server-2` service in `docker-compose.yml` to test multi-host playbooks:

```bash
docker compose up -d --scale ubuntu-server-2=1
```

Update your inventory to include multiple hosts:

```ini
[test_servers]
ubuntu-test-1 ansible_host=localhost ansible_port=2222 ansible_user=ubuntu ansible_password=ubuntu
ubuntu-test-2 ansible_host=localhost ansible_port=2223 ansible_user=ubuntu ansible_password=ubuntu

[test_servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
```

---

## 🧹 Cleanup

```bash
# Stop and remove containers
docker compose down

# Remove volumes (careful: this deletes all data)
docker compose down -v

# Remove the image
docker rmi docker-ubuntu-systemd
```

---

## ⚠️ Important Notes

1. **Privileged Mode**: The container runs in privileged mode to support systemd. This is normal for systemd containers but should only be used in testing environments.

2. **Security**: Default passwords are set for convenience. Never use this configuration in production or expose the container to untrusted networks.

3. **Performance**: systemd containers use more resources than minimal containers. This is expected for full system simulation.

4. **Persistence**: Container state is ephemeral by default. To persist data, mount volumes for specific directories.

---

## 🔍 Troubleshooting

### systemd not starting
- Ensure the container is running with `--privileged` flag
- Check that cgroups are properly mounted: `-v /sys/fs/cgroup:/sys/fs/cgroup:rw`

### SSH connection refused
- Wait a few seconds after starting for SSH to initialize
- Check if the container is running: `docker ps`
- Verify port mapping: `docker port ubuntu-systemd-test`

### Ansible connection issues
- Verify SSH works manually first
- Use `-vvv` flag with ansible for verbose output
- Check the container logs: `docker compose logs`

---

## 🎨 Customization

### Adding More Packages

Edit the `Dockerfile` and add packages to the `apt-get install` command:

```dockerfile
RUN apt-get update && \
    apt-get install -y \
    # ... existing packages ...
    nginx \
    postgresql \
    redis-server \
    && apt-get clean
```

### Custom SSH Keys

Mount your SSH public key:

```yaml
volumes:
  - ~/.ssh/id_rsa.pub:/root/.ssh/authorized_keys:ro
```

### Persistent Storage

Add volumes for data persistence:

```yaml
volumes:
  - ./data:/var/lib/data
  - ./logs:/var/log
```

---

## 📚 Example Playbooks

This repository includes several example Ansible playbooks in the `examples/playbooks/` directory:

- **nginx-setup.yml** - Install and configure Nginx web server
- **docker-install.yml** - Install Docker Engine and Docker Compose
- **user-management.yml** - Create users, groups, and manage permissions
- **systemd-service.yml** - Create custom systemd services and timers
- **security-hardening.yml** - Apply basic security hardening

Run any playbook using:

```bash
# Using the quick start script
./run.sh test-nginx

# Using Make
make test-nginx

# Using ansible-playbook directly
cd examples
ansible-playbook -i inventory.yml playbooks/nginx-setup.yml
```

See the [examples/README.md](examples/README.md) for detailed documentation.

---

## 📦 Using Pre-built Images

Images are automatically built and published to GitHub Container Registry when you push to the main branch or create a tag.

**Latest image**: `ghcr.io/zuptalo/docker-ubuntu-systemd:latest`

```bash
# Pull the latest image
docker pull ghcr.io/zuptalo/docker-ubuntu-systemd:latest

# Or use a specific version
docker pull ghcr.io/zuptalo/docker-ubuntu-systemd:v1.0.0

# Run using the compose file in examples/
cd examples
docker compose up -d
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 Fork the repository
2. 🔧 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add some amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🎉 Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Commit Message Guidelines

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated releases:

- `feat:` - New features (minor version bump)
- `fix:` - Bug fixes (patch version bump)
- `docs:` - Documentation changes (patch version bump)
- `chore:` - Maintenance tasks (no version bump)
- `BREAKING CHANGE:` - Breaking changes (major version bump)

Example:
```bash
git commit -m "feat: add PostgreSQL example playbook"
git commit -m "fix: correct SSH port in docker-compose"
```

Releases are automatically created when you push to the `main` branch!

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Show Your Support

If you find this project useful, please consider:

- ⭐ Starring the repository
- 🐛 Reporting bugs or suggesting features via [Issues](https://github.com/zuptalo/docker-ubuntu-systemd/issues)
- 📢 Sharing it with others who might benefit

---

## 📊 Project Stats

![GitHub repo size](https://img.shields.io/github/repo-size/zuptalo/docker-ubuntu-systemd)
![GitHub contributors](https://img.shields.io/github/contributors/zuptalo/docker-ubuntu-systemd)
![GitHub last commit](https://img.shields.io/github/last-commit/zuptalo/docker-ubuntu-systemd)
![GitHub issues](https://img.shields.io/github/issues/zuptalo/docker-ubuntu-systemd)
![GitHub pull requests](https://img.shields.io/github/issues-pr/zuptalo/docker-ubuntu-systemd)

---

<div align="center">

**Made with ❤️ for the DevOps community**

[Report Bug](https://github.com/zuptalo/docker-ubuntu-systemd/issues) · [Request Feature](https://github.com/zuptalo/docker-ubuntu-systemd/issues) · [Documentation](https://github.com/zuptalo/docker-ubuntu-systemd/wiki)

</div>