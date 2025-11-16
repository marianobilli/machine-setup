#!/usr/bin/env bash

# Install envchain on Ubuntu
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

    # Build from source
    sudo apt install -y build-essential libsecret-1-dev libreadline-dev

    # Create ~/github directory if it doesn't exist
    mkdir -p ~/github

    # Clone or update envchain repository
    if [ -d ~/github/envchain ]; then
        log_info "Updating existing envchain repository..."
        cd ~/github/envchain || return 1
        git pull
    else
        log_info "Cloning envchain repository..."
        git clone https://github.com/sorah/envchain.git ~/github/envchain
        cd ~/github/envchain || return 1
    fi

    # Build and install
    make
    sudo make install
    cd ~ || return 1

    log_info "envchain installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_envchain
fi
