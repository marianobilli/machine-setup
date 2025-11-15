#!/usr/bin/env bash

# Install wslu on Ubuntu (for WSL)
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_wslu() {
    # Check if wslu is already installed
    if command -v wslview &> /dev/null; then
        log_info "wslu is already installed"
        return 0
    fi

    log_info "Installing wslu (for WSL browser integration)..."

    sudo apt update
    sudo apt install -y wslu

    log_info "wslu installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wslu
fi
