#!/usr/bin/env bash

# Install Claude Code
# This script works on both macOS and Ubuntu

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_claude_code() {
    log_info "Installing Claude Code..."

    if command -v claude &> /dev/null; then
        log_info "Claude Code is already installed"
        return 0
    fi

    # Install via npm globally
    sudo npm install -g @anthropic-ai/claude-code

    log_info "Claude Code installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_code
fi
