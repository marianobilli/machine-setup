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
        # Ensure dbus-x11 is installed (needed for dbus-launch)
        if ! dpkg -l | grep -q dbus-x11; then
            log_info "Installing dbus-x11 (required for dbus-launch)..."
            sudo apt install -y dbus-x11
        fi
    else
        log_info "Installing gnome-keyring..."
        sudo apt update
        sudo apt install -y gnome-keyring libsecret-1-0 libsecret-1-dev dbus-x11
        log_info "gnome-keyring installed successfully"
    fi

    # Configure gnome-keyring to start automatically in .zshrc
    if [ -f ~/.zshrc ]; then
        if ! grep -q "gnome-keyring-daemon" ~/.zshrc; then
            log_info "Configuring gnome-keyring daemon to start automatically..."
            cat >> ~/.zshrc << 'GNOME_EOF'

# === GNOME Keyring Daemon - START ===
# Start GNOME Keyring if not running (required for credential storage like envchain/assume)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi
if [ -z "$GNOME_KEYRING_CONTROL" ]; then
    # Start gnome-keyring-daemon with secrets, ssh, and pkcs11 components
    eval $(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh 2>/dev/null)
    # Ensure environment variables are exported
    export SSH_AUTH_SOCK
    export GNOME_KEYRING_CONTROL
    export GNOME_KEYRING_PID
fi
# === GNOME Keyring Daemon - END ===
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
