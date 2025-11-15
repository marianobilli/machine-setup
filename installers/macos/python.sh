#!/usr/bin/env bash

# Install Python 3.12 on macOS
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_python() {
    # Check if Python 3.12 is already installed
    if command -v python3.12 &> /dev/null; then
        log_info "Python 3.12 is already installed"
        return 0
    fi

    log_info "Installing Python 3.12..."

    brew install python@3.12
    # Link python3.12 to python3
    brew link python@3.12

    log_info "Python 3.12 installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_python
fi
