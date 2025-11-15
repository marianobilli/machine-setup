#!/usr/bin/env bash

# Install kubectl on Ubuntu
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_kubectl() {
    # Check if kubectl is already installed
    if command -v kubectl &> /dev/null; then
        log_info "kubectl is already installed (version: $(kubectl version --client --short 2>/dev/null || echo 'installed'))"
        return 0
    fi

    log_info "Installing kubectl for AWS..."

    # Install kubectl from official Kubernetes repository
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl

    # Create keyrings directory if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings

    # Only add key if not already present
    if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    fi

    # Only add repository if not already present
    if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    fi

    sudo apt update
    sudo apt install -y kubectl

    log_info "kubectl installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_kubectl
fi
