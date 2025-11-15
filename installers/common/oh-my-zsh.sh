#!/usr/bin/env bash

# Install Oh My Zsh with Powerlevel10k
# This script works on both macOS and Ubuntu

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_oh_my_zsh() {
    # Check if Oh My Zsh is already installed
    if [ -d ~/.oh-my-zsh ]; then
        log_info "Oh My Zsh is already installed"
    else
        log_info "Installing Oh My Zsh..."

        # Install Oh My Zsh (unattended)
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        log_info "Oh My Zsh installed successfully"
    fi

    # Install Powerlevel10k theme (but don't force it if user has different theme)
    if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        log_info "Powerlevel10k theme is already installed (not updating to preserve your configuration)"
    else
        log_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
        log_info "Powerlevel10k theme installed successfully"

        # Only set theme if this is a fresh installation and no theme is set
        if [ -f ~/.zshrc ]; then
            if ! grep -q "^ZSH_THEME=" ~/.zshrc; then
                echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
                log_info "Set Powerlevel10k as default theme"
            else
                log_info "Existing theme detected - not changing it. To use Powerlevel10k, set: ZSH_THEME=\"powerlevel10k/powerlevel10k\""
            fi
        fi
    fi

    # Install zsh-autosuggestions plugin
    if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
        log_info "zsh-autosuggestions is already installed (not updating to preserve your configuration)"
    else
        log_info "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        log_info "zsh-autosuggestions plugin installed successfully"
    fi

    # Install zsh-syntax-highlighting plugin
    if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        log_info "zsh-syntax-highlighting is already installed (not updating to preserve your configuration)"
    else
        log_info "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        log_info "zsh-syntax-highlighting plugin installed successfully"
    fi

    # Backup existing .zshrc if it exists and wasn't backed up yet
    if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.backup-before-setup ]; then
        cp ~/.zshrc ~/.zshrc.backup-before-setup
        log_info "Backed up existing .zshrc to ~/.zshrc.backup-before-setup"
    fi

    # Ensure required plugins are present (without removing user's existing plugins)
    REQUIRED_PLUGINS=("git" "docker" "kubectl" "aws" "kubernetes" "zsh-autosuggestions" "zsh-syntax-highlighting" "npm" "python" "command-not-found" "colored-man-pages" "z" "history-substring-search" "sudo" "extract")

    if [ -f ~/.zshrc ]; then
        if grep -q "^plugins=" ~/.zshrc; then
            # Extract current plugins
            CURRENT_PLUGINS=$(grep "^plugins=" ~/.zshrc | sed 's/plugins=(\(.*\))/\1/')

            # Check which required plugins are missing
            MISSING_PLUGINS=()
            for plugin in "${REQUIRED_PLUGINS[@]}"; do
                if ! echo "$CURRENT_PLUGINS" | grep -qw "$plugin"; then
                    MISSING_PLUGINS+=("$plugin")
                fi
            done

            # Add missing plugins to the existing line
            if [ ${#MISSING_PLUGINS[@]} -gt 0 ]; then
                log_info "Adding missing plugins: ${MISSING_PLUGINS[*]}"

                # Build new plugin list (existing + missing)
                NEW_PLUGINS="$CURRENT_PLUGINS ${MISSING_PLUGINS[*]}"
                NEW_PLUGINS=$(echo "$NEW_PLUGINS" | xargs)  # trim whitespace

                # Update the plugins line
                sed -i.tmp "s|^plugins=.*|plugins=($NEW_PLUGINS)|" ~/.zshrc
                rm -f ~/.zshrc.tmp

                log_info "Plugins updated successfully"
            else
                log_info "All required plugins already present"
            fi
        else
            # No plugins line exists, add it
            echo "plugins=(${REQUIRED_PLUGINS[*]})" >> ~/.zshrc
            log_info "Added plugins: ${REQUIRED_PLUGINS[*]}"
        fi
    fi

    log_info "Oh My Zsh setup complete"
    if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        log_warning "Powerlevel10k is available. Run 'p10k configure' to customize (if not already done)"
    fi
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_oh_my_zsh
fi
