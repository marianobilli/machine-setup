#!/usr/bin/env bash

# Install Node.js
# Handles both macOS and Ubuntu with OS-specific setup

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_nodejs() {
    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        log_info "Node.js is already installed (version: $(node --version))"
        return 0
    fi

    log_info "Installing Node.js and npm..."

    if [[ "$OS" == "macos" ]]; then
        brew install node
    elif [[ "$OS" == "ubuntu" ]]; then
        # Install using NodeSource repository for latest LTS
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    fi

    log_info "Node.js and npm installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nodejs
fi
