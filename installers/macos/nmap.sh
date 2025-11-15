#!/usr/bin/env bash

# Install nmap on macOS
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_nmap() {
    # Check if nmap is already installed
    if command -v nmap &> /dev/null; then
        log_info "nmap is already installed (version: $(nmap --version | head -n 1))"
        return 0
    fi

    log_info "Installing nmap..."

    brew install nmap

    log_info "nmap installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nmap
fi
