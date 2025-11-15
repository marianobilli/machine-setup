#!/usr/bin/env bash

# Install kubectl on macOS
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

    brew install kubectl

    log_info "kubectl installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_kubectl
fi
