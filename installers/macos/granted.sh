#!/usr/bin/env bash

# Install Granted (assume) on macOS
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_granted() {
    # Check if granted is already installed
    if command -v granted &> /dev/null; then
        log_info "Granted is already installed"

        # Still check and add alias if missing
        if ! grep -q "alias assume=" ~/.zshrc 2>/dev/null; then
            echo 'alias assume="source assume"' >> ~/.zshrc
        fi

        return 0
    fi

    log_info "Installing Granted (assume)..."

    brew tap common-fate/granted
    brew install granted

    # Add assume alias to zshrc if not already present
    if ! grep -q "alias assume=" ~/.zshrc 2>/dev/null; then
        echo 'alias assume="source assume"' >> ~/.zshrc
    fi

    log_info "Granted installed successfully"
    log_warning "Please restart your shell or run 'source ~/.zshrc' to use the assume alias"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_granted
fi
