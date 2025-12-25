# Contributing to Ubuntu Systemd Docker Container

Thank you for considering contributing to this project! We welcome contributions from the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please be respectful and constructive in your interactions.

## How to Contribute

1. **Fork the repository** - Click the "Fork" button at the top right of the repository page
2. **Clone your fork** - `git clone git@github.com:YOUR-USERNAME/docker-ubuntu-systemd.git`
3. **Create a branch** - `git checkout -b feature/your-feature-name`
4. **Make your changes** - Follow the commit message guidelines below
5. **Test your changes** - Ensure the Docker image builds and runs correctly
6. **Commit your changes** - Use conventional commits (see below)
7. **Push to your fork** - `git push origin feature/your-feature-name`
8. **Open a Pull Request** - Go to the original repository and click "New Pull Request"

## Commit Message Guidelines

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated versioning and changelog generation.

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature (triggers a minor version bump)
- **fix**: A bug fix (triggers a patch version bump)
- **docs**: Documentation only changes (triggers a patch version bump)
- **refactor**: Code changes that neither fix a bug nor add a feature (triggers a patch version bump)
- **perf**: Performance improvements (triggers a patch version bump)
- **test**: Adding or updating tests (no version bump)
- **build**: Changes to build system or dependencies (triggers a patch version bump)
- **ci**: Changes to CI configuration files and scripts (no version bump)
- **chore**: Other changes that don't modify src or test files (no version bump)

### Breaking Changes

Add `BREAKING CHANGE:` in the footer or append `!` after the type to trigger a major version bump:

```
feat!: remove ubuntu user default password

BREAKING CHANGE: The ubuntu user no longer has a default password.
Users must now provide SSH keys for authentication.
```

### Examples

```bash
# Feature addition (bumps version from 1.0.0 to 1.1.0)
git commit -m "feat: add PostgreSQL to example playbooks"

# Bug fix (bumps version from 1.0.0 to 1.0.1)
git commit -m "fix: correct SSH configuration for password auth"

# Documentation update (bumps version from 1.0.0 to 1.0.1)
git commit -m "docs: update installation instructions"

# Breaking change (bumps version from 1.0.0 to 2.0.0)
git commit -m "feat!: upgrade to Ubuntu 26.04"

# No version bump
git commit -m "chore: update .gitignore"
git commit -m "ci: update GitHub Actions workflow"
```

## Development Setup

### Prerequisites

- Docker
- Docker Compose
- Git
- (Optional) Ansible for testing playbooks

### Building Locally

```bash
# Clone the repository
git clone git@github.com:zuptalo/docker-ubuntu-systemd.git
cd docker-ubuntu-systemd

# Build the image
docker compose build

# Run the container
docker compose up -d

# Test SSH access
ssh ubuntu@localhost -p 2222
# Password: ubuntu
```

### Testing Changes

Before submitting a pull request:

1. **Build the image** - Ensure it builds without errors
   ```bash
   docker compose build
   ```

2. **Test the container** - Verify it starts and systemd works
   ```bash
   docker compose up -d
   docker exec ubuntu-systemd-test systemctl status
   ```

3. **Test with Ansible** - Run the example playbooks
   ```bash
   cd examples
   ansible all -i inventory.yml -m ping
   ansible-playbook -i inventory.yml playbooks/nginx-setup.yml
   ```

4. **Clean up** - Remove containers and volumes
   ```bash
   docker compose down -v
   ```

## Pull Request Process

1. **Update documentation** - If your changes affect usage, update the README.md
2. **Update examples** - If adding new features, consider adding example playbooks
3. **Follow commit conventions** - Use conventional commits for all commits
4. **Ensure CI passes** - GitHub Actions will run automated tests
5. **Request review** - Wait for maintainer review
6. **Address feedback** - Make requested changes if any
7. **Merge** - Maintainers will merge once approved

### Pull Request Title

Use conventional commit format for PR titles too:

```
feat: add Redis example playbook
fix: correct systemd service configuration
docs: improve quick start guide
```

## Automated Releases

This project uses [semantic-release](https://semantic-release.gitbook.io/) for automated versioning:

- Commits to `main` branch trigger the release workflow
- Version is determined by commit messages (conventional commits)
- Changelog is automatically generated
- GitHub release is created
- Docker image is tagged with the new version

You don't need to manually create tags or releases - just use proper commit messages!

## Questions?

If you have questions or need help, please:

- Open an [issue](https://github.com/zuptalo/docker-ubuntu-systemd/issues)
- Check existing issues and discussions
- Reach out to maintainers

Thank you for contributing! 🎉
