.PHONY: help build run start stop restart logs shell ssh clean test test-nginx test-docker test-all examples pull dev prod

# Default target
help:
	@echo "Ubuntu Systemd Container - Available commands:"
	@echo ""
	@echo "Quick Start (using pre-built image):"
	@echo "  make prod           - Run using pre-built image from GHCR"
	@echo "  make pull           - Pull the latest image from GHCR"
	@echo ""
	@echo "Development (building from source):"
	@echo "  make dev            - Build and start using local Dockerfile"
	@echo "  make build          - Build the Docker image from source"
	@echo "  make run            - Build and start the container (dev mode)"
	@echo "  make start          - Start the container (dev mode)"
	@echo "  make stop           - Stop the container"
	@echo "  make restart        - Restart the container"
	@echo ""
	@echo "Accessing the Container:"
	@echo "  make logs           - View container logs"
	@echo "  make shell          - Open a bash shell in the container"
	@echo "  make ssh            - SSH into the container as ubuntu user"
	@echo "  make ssh-root       - SSH into the container as root"
	@echo ""
	@echo "Testing with Ansible:"
	@echo "  make test           - Run Ansible ping test"
	@echo "  make test-nginx     - Run nginx setup playbook"
	@echo "  make test-docker    - Run docker installation playbook"
	@echo "  make test-systemd   - Run systemd service playbook"
	@echo "  make test-users     - Run user management playbook"
	@echo "  make test-security  - Run security hardening playbook"
	@echo "  make test-all       - Run all test playbooks"
	@echo ""
	@echo "Examples and Cleanup:"
	@echo "  make examples       - Start containers using the examples"
	@echo "  make pull           - Pull the latest image from GHCR"
	@echo "  make clean          - Stop and remove containers and volumes"
	@echo "  make clean-all      - Remove everything including images"

# Production mode - use pre-built image
prod:
	docker compose -f compose.yaml up -d
	@echo "Waiting for SSH to be ready..."
	@sleep 5
	@echo "Container is ready (using pre-built image)!"
	@echo "SSH: ssh ubuntu@localhost -p 2222 (password: ubuntu)"

# Development mode - build from source
dev: build start

# Build the image from source
build:
	docker compose -f compose.dev.yml build

# Build and start (development)
run: build start

# Start container (development)
start:
	docker compose -f compose.dev.yml up -d
	@echo "Waiting for SSH to be ready..."
	@sleep 5
	@echo "Container is ready (development mode)!"
	@echo "SSH: ssh ubuntu@localhost -p 2222 (password: ubuntu)"

# Stop container (works for both dev and prod)
stop:
	docker compose -f compose.dev.yml down 2>/dev/null || true
	docker compose -f compose.yaml down 2>/dev/null || true

# Restart container
restart: stop start

# View logs
logs:
	docker compose logs -f

# Open shell in container (tries dev first, then prod)
shell:
	@docker exec -it ubuntu-systemd-test-dev bash 2>/dev/null || docker exec -it ubuntu-systemd-test bash

# SSH as ubuntu user
ssh:
	@echo "Connecting as ubuntu user (password: ubuntu)..."
	@ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@localhost -p 2222

# SSH as root
ssh-root:
	@echo "Connecting as root (password: root)..."
	@ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222

# Clean up containers and volumes
clean:
	docker compose -f compose.dev.yml down -v 2>/dev/null || true
	docker compose -f compose.yaml down -v 2>/dev/null || true

# Clean everything including images
clean-all: clean
	docker rmi docker-ubuntu-systemd 2>/dev/null || true
	docker rmi ghcr.io/zuptalo/docker-ubuntu-systemd:latest 2>/dev/null || true

# Pull latest image from GHCR
pull:
	docker pull ghcr.io/$${GITHUB_REPOSITORY:-$(shell git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')}:latest

# Ansible tests
test:
	@echo "Testing Ansible connectivity..."
	@cd examples && ansible all -i inventory.yml -m ping

test-nginx:
	@echo "Running Nginx setup playbook..."
	@cd examples && ansible-playbook -i inventory.yml playbooks/nginx-setup.yml

test-docker:
	@echo "Running Docker installation playbook..."
	@cd examples && ansible-playbook -i inventory.yml playbooks/docker-install.yml

test-systemd:
	@echo "Running systemd service playbook..."
	@cd examples && ansible-playbook -i inventory.yml playbooks/systemd-service.yml

test-users:
	@echo "Running user management playbook..."
	@cd examples && ansible-playbook -i inventory.yml playbooks/user-management.yml

test-security:
	@echo "Running security hardening playbook..."
	@cd examples && ansible-playbook -i inventory.yml playbooks/security-hardening.yml

test-all: test test-nginx test-systemd test-users
	@echo "All tests completed!"

# Run examples
examples:
	@echo "Starting examples with Ansible controller..."
	cd examples && docker compose up
