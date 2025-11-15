#!/usr/bin/env bash

# Install kubectx on macOS
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_kubectx() {
    # Check if kubectx is already installed
    if command -v kubectx &> /dev/null; then
        log_info "kubectx is already installed"
        return 0
    fi

    log_info "Installing kubectx..."

    brew install kubectx

    log_info "kubectx installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_kubectx
fi
