#!/usr/bin/env bash

# Install lsof on Ubuntu
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_lsof() {
    # Check if lsof is already installed
    if command -v lsof &> /dev/null; then
        log_info "lsof is already installed"
        return 0
    fi

    log_info "Installing lsof..."

    sudo apt update
    sudo apt install -y lsof

    log_info "lsof installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_lsof
fi
