#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Show help
show_help() {
    cat << EOF
Ubuntu Systemd Container - Quick Start Script

Usage: ./run.sh [command]

Commands:
  Quick Start (using pre-built image):
    prod            - Run using pre-built image from GHCR
    pull            - Pull latest image from GHCR

  Development (building from source):
    dev             - Build and start from source (development mode)
    start           - Build and start from source (alias for dev)
    build           - Build the image from source only

  Container Management:
    stop            - Stop the container
    restart         - Restart the container
    clean           - Stop and remove containers

  Access:
    ssh             - SSH into the container as ubuntu user
    ssh-root        - SSH into the container as root
    shell           - Open bash shell in the container
    logs            - View container logs

  Testing:
    test            - Run Ansible connectivity test
    test-nginx      - Run nginx installation playbook
    test-docker     - Run docker installation playbook
    test-systemd    - Run systemd service playbook
    test-all        - Run all example playbooks
    examples        - Run the examples with Ansible controller

  Help:
    help            - Show this help message

Examples:
  ./run.sh prod               # Quick start with pre-built image
  ./run.sh dev                # Development mode (build from source)
  ./run.sh test-nginx         # Install nginx with Ansible
  ./run.sh ssh                # Connect via SSH
EOF
}

# Check if docker and docker compose are available
check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available"
        exit 1
    fi
}

# Start container in production mode (pre-built image)
start_prod() {
    print_header "Starting Container (Pre-built Image)"
    docker compose -f compose.yaml up -d
    print_info "Waiting for SSH to be ready..."
    sleep 5
    print_success "Container is ready (using pre-built image)!"
    echo ""
    print_info "SSH access: ssh ubuntu@localhost -p 2222 (password: ubuntu)"
    print_info "Or run: ./run.sh ssh"
}

# Start container in development mode (build from source)
start_dev() {
    print_header "Building and Starting Container (Development Mode)"
    docker compose -f compose.dev.yml up -d --build
    print_info "Waiting for SSH to be ready..."
    sleep 5
    print_success "Container is ready (development mode)!"
    echo ""
    print_info "SSH access: ssh ubuntu@localhost -p 2222 (password: ubuntu)"
    print_info "Or run: ./run.sh ssh"
}

# Build only
build_image() {
    print_header "Building Docker Image from Source"
    docker compose -f compose.dev.yml build
    print_success "Build complete!"
}

# Pull latest image
pull_image() {
    print_header "Pulling Latest Image from GHCR"
    docker pull ghcr.io/zuptalo/docker-ubuntu-systemd:latest
    print_success "Pull complete!"
}

# Stop container
stop_container() {
    print_header "Stopping Container"
    docker compose -f compose.dev.yml down 2>/dev/null || true
    docker compose -f compose.yaml down 2>/dev/null || true
    print_success "Container stopped"
}

# Restart container
restart_container() {
    stop_container
    print_info "Choose mode: [d]ev or [p]rod? (default: dev)"
    read -r mode
    case "$mode" in
        p|prod)
            start_prod
            ;;
        *)
            start_dev
            ;;
    esac
}

# SSH into container
ssh_container() {
    print_header "Connecting via SSH as ubuntu user"
    print_info "Password: ubuntu"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@localhost -p 2222
}

# SSH as root
ssh_root() {
    print_header "Connecting via SSH as root"
    print_info "Password: root"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 2222
}

# Open shell
shell() {
    print_header "Opening Shell in Container"
    # Try dev container first, then prod
    docker exec -it ubuntu-systemd-test-dev bash 2>/dev/null || docker exec -it ubuntu-systemd-test bash
}

# View logs
view_logs() {
    print_header "Container Logs"
    # Try to determine which container is running
    if docker ps | grep -q ubuntu-systemd-test-dev; then
        docker logs -f ubuntu-systemd-test-dev
    elif docker ps | grep -q ubuntu-systemd-test; then
        docker logs -f ubuntu-systemd-test
    else
        print_error "No container is running"
        exit 1
    fi
}

# Run Ansible tests
ansible_test() {
    print_header "Testing Ansible Connectivity"
    cd examples
    ansible all -i inventory.yml -m ping
    cd ..
    print_success "Ansible connectivity test passed!"
}

# Run nginx playbook
test_nginx() {
    print_header "Running Nginx Setup Playbook"
    cd examples
    ansible-playbook -i inventory.yml playbooks/nginx-setup.yml
    cd ..
    print_success "Nginx playbook completed!"
}

# Run docker playbook
test_docker() {
    print_header "Running Docker Installation Playbook"
    cd examples
    ansible-playbook -i inventory.yml playbooks/docker-install.yml
    cd ..
    print_success "Docker installation playbook completed!"
}

# Run systemd playbook
test_systemd() {
    print_header "Running Systemd Service Playbook"
    cd examples
    ansible-playbook -i inventory.yml playbooks/systemd-service.yml
    cd ..
    print_success "Systemd playbook completed!"
}

# Run all test playbooks
test_all() {
    ansible_test
    test_nginx
    test_systemd
    print_success "All tests completed!"
}

# Run examples with Ansible controller
run_examples() {
    print_header "Running Examples with Ansible Controller"
    cd examples
    docker compose up
    cd ..
}

# Clean up
clean() {
    print_header "Cleaning Up"
    docker compose -f compose.dev.yml down -v 2>/dev/null || true
    docker compose -f compose.yaml down -v 2>/dev/null || true
    print_success "Cleanup complete"
}

# Check requirements first
check_requirements

# Main command handler
case "${1:-help}" in
    prod)
        start_prod
        ;;
    dev|start)
        start_dev
        ;;
    build)
        build_image
        ;;
    pull)
        pull_image
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    ssh)
        ssh_container
        ;;
    ssh-root)
        ssh_root
        ;;
    shell)
        shell
        ;;
    logs)
        view_logs
        ;;
    test)
        ansible_test
        ;;
    test-nginx)
        test_nginx
        ;;
    test-docker)
        test_docker
        ;;
    test-systemd)
        test_systemd
        ;;
    test-all)
        test_all
        ;;
    examples)
        run_examples
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
