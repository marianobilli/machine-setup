#!/usr/bin/env bash

# Install kubectx on Ubuntu
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

    # Create ~/github directory if it doesn't exist
    mkdir -p ~/github

    # Check if already cloned, if so pull latest, otherwise clone
    if [ -d ~/github/kubectx ]; then
        log_info "Updating existing kubectx installation..."
        cd ~/github/kubectx || return 1
        git pull
        cd ~ || return 1
    else
        # Clone from GitHub
        git clone https://github.com/ahmetb/kubectx ~/github/kubectx
    fi

    sudo ln -sf ~/github/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf ~/github/kubectx/kubens /usr/local/bin/kubens

    # Install completion for zsh
    mkdir -p ~/.oh-my-zsh/completions
    chmod -R 755 ~/.oh-my-zsh/completions
    ln -sf ~/github/kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/completions/_kubectx.zsh
    ln -sf ~/github/kubectx/completion/_kubens.zsh ~/.oh-my-zsh/completions/_kubens.zsh

    log_info "kubectx installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_kubectx
fi
