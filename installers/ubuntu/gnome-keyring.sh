#!/usr/bin/env bash

# Install and configure gnome-keyring on Ubuntu
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_gnome_keyring() {
    # Check if gnome-keyring is already installed
    if dpkg -l | grep -q gnome-keyring; then
        log_info "gnome-keyring is already installed"
    else
        log_info "Installing gnome-keyring..."
        sudo apt update
        sudo apt install -y gnome-keyring libsecret-1-0 libsecret-1-dev
        log_info "gnome-keyring installed successfully"
    fi

    # Configure gnome-keyring to start automatically in .zshrc
    if [ -f ~/.zshrc ]; then
        if ! grep -q "gnome-keyring-daemon" ~/.zshrc; then
            log_info "Configuring gnome-keyring daemon to start automatically..."
            cat >> ~/.zshrc << 'GNOME_EOF'

# Start gnome-keyring daemon if not already running
if [ -z "$GNOME_KEYRING_CONTROL" ]; then
    eval $(gnome-keyring-daemon --start --components=secrets,ssh 2>/dev/null)
    export GNOME_KEYRING_CONTROL
    export SSH_AUTH_SOCK
fi
GNOME_EOF
            log_info "gnome-keyring daemon configuration added to ~/.zshrc"
        else
            log_info "gnome-keyring daemon is already configured in ~/.zshrc"
        fi
    fi

    # Configure git to use gnome-keyring as credential helper
    if command -v git &> /dev/null; then
        CURRENT_HELPER=$(git config --global credential.helper 2>/dev/null || echo "")

        if [[ "$CURRENT_HELPER" != *"libsecret"* ]]; then
            log_info "Configuring git to use gnome-keyring for credential storage..."

            # Build git-credential-libsecret if not already built
            if [ ! -f /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret ]; then
                log_info "Building git-credential-libsecret..."
                sudo apt install -y libglib2.0-dev
                cd /usr/share/doc/git/contrib/credential/libsecret || return 1
                sudo make
                cd ~ || return 1
            fi

            git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
            log_info "git credential helper configured to use gnome-keyring"
        else
            log_info "git is already configured to use gnome-keyring"
        fi
    fi

    # Configure for granted/assume (envchain already uses libsecret-1-dev)
    log_info "gnome-keyring is configured for granted/assume (via libsecret)"

    log_info "gnome-keyring setup complete"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_gnome_keyring
fi
