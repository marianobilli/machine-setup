#!/usr/bin/env bash

# Configure Granted (assume) alias
# Granted itself is installed via package manager, but needs alias setup

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

configure_granted() {
    # Check if granted is installed
    if ! command -v granted &> /dev/null; then
        log_warning "Granted is not installed. Skipping alias configuration."
        return 0
    fi

    # Add assume alias to zshrc if not already present
    if [ -f ~/.zshrc ]; then
        if ! grep -q "alias assume=" ~/.zshrc 2>/dev/null; then
            log_info "Adding assume alias to ~/.zshrc"
            echo 'alias assume="source assume"' >> ~/.zshrc
            log_success "Granted alias configured"
            log_warning "Please restart your shell or run 'source ~/.zshrc' to use the assume alias"
        else
            log_info "Granted assume alias is already configured"
        fi
    else
        log_warning "~/.zshrc not found. Please add: alias assume=\"source assume\""
    fi
}

# Run configuration if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_granted
fi
