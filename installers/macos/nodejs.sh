#!/usr/bin/env bash

# Install Node.js and npm on macOS
# This script should be sourced or called from the main setup script

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

    brew install node

    log_info "Node.js and npm installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nodejs
fi
