#!/usr/bin/env bash

# Install envchain on macOS
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_envchain() {
    # Check if envchain is already installed
    if command -v envchain &> /dev/null; then
        log_info "envchain is already installed"
        return 0
    fi

    log_info "Installing envchain..."

    brew install envchain

    log_info "envchain installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_envchain
fi
