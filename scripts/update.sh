#!/usr/bin/env bash

# Update script - Update installed tools to latest versions
# This script checks for updates and installs newer versions

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Load versions
load_versions

# Detect OS
OS=$(detect_os)

# Update counters
TOTAL_UPDATES=0
SUCCESSFUL_UPDATES=0
FAILED_UPDATES=0
SKIPPED_UPDATES=0

# Update Homebrew (macOS only)
update_brew() {
    if [[ "$OS" != "macos" ]]; then
        return 0
    fi

    if ! command_exists brew; then
        return 0
    fi

    log_info "Updating Homebrew..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if brew update; then
        log_success "Homebrew updated successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_error "Failed to update Homebrew"
        FAILED_UPDATES=$((FAILED_UPDATES + 1))
    fi
}

# Update Oh My Zsh
update_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        return 0
    fi

    log_info "Updating Oh My Zsh..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if [ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]; then
        if env ZSH="$HOME/.oh-my-zsh" sh "$HOME/.oh-my-zsh/tools/upgrade.sh"; then
            log_success "Oh My Zsh updated successfully"
            SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
        else
            log_error "Failed to update Oh My Zsh"
            FAILED_UPDATES=$((FAILED_UPDATES + 1))
        fi
    else
        log_warning "Oh My Zsh upgrade script not found"
        SKIPPED_UPDATES=$((SKIPPED_UPDATES + 1))
    fi
}

# Update Powerlevel10k
update_powerlevel10k() {
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

    if [ ! -d "$p10k_dir" ]; then
        return 0
    fi

    log_info "Updating Powerlevel10k theme..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    cd "$p10k_dir"
    if git pull; then
        log_success "Powerlevel10k updated successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_error "Failed to update Powerlevel10k"
        FAILED_UPDATES=$((FAILED_UPDATES + 1))
    fi
    cd - > /dev/null
}

# Update zsh plugins
update_zsh_plugins() {
    local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")

    for plugin in "${plugins[@]}"; do
        local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin"

        if [ ! -d "$plugin_dir" ]; then
            continue
        fi

        log_info "Updating $plugin..."
        TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

        cd "$plugin_dir"
        if git pull; then
            log_success "$plugin updated successfully"
            SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
        else
            log_error "Failed to update $plugin"
            FAILED_UPDATES=$((FAILED_UPDATES + 1))
        fi
        cd - > /dev/null
    done
}

# Update Python packages
update_python() {
    if ! command_exists python3; then
        return 0
    fi

    log_info "Updating pip..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if python3 -m pip install --upgrade pip --user; then
        log_success "pip updated successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_warning "Failed to update pip (may require different permissions)"
        SKIPPED_UPDATES=$((SKIPPED_UPDATES + 1))
    fi
}

# Update Node.js packages
update_nodejs() {
    if ! command_exists npm; then
        return 0
    fi

    log_info "Checking npm updates..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if sudo npm update -g; then
        log_success "Global npm packages updated"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_warning "Failed to update npm packages"
        SKIPPED_UPDATES=$((SKIPPED_UPDATES + 1))
    fi
}

# Update Claude Code
update_claude_code() {
    if ! command_exists claude; then
        return 0
    fi

    log_info "Updating Claude Code..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if sudo npm update -g @anthropic-ai/claude-code; then
        log_success "Claude Code updated successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_error "Failed to update Claude Code"
        FAILED_UPDATES=$((FAILED_UPDATES + 1))
    fi
}

# Update kubectx (Ubuntu only)
update_kubectx() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    local kubectx_dir="$HOME/github/kubectx"

    if [ ! -d "$kubectx_dir" ]; then
        return 0
    fi

    log_info "Updating kubectx..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    cd "$kubectx_dir"
    if git pull; then
        log_success "kubectx updated successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_error "Failed to update kubectx"
        FAILED_UPDATES=$((FAILED_UPDATES + 1))
    fi
    cd - > /dev/null
}

# Update envchain (Ubuntu only)
update_envchain() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    local envchain_dir="$HOME/github/envchain"

    if [ ! -d "$envchain_dir" ]; then
        return 0
    fi

    log_info "Updating envchain..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    cd "$envchain_dir"
    if git pull; then
        # Rebuild if there were changes
        if make && sudo make install; then
            log_success "envchain updated and rebuilt successfully"
            SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
        else
            log_error "Failed to rebuild envchain"
            FAILED_UPDATES=$((FAILED_UPDATES + 1))
        fi
    else
        log_error "Failed to update envchain"
        FAILED_UPDATES=$((FAILED_UPDATES + 1))
    fi
    cd - > /dev/null
}

# Update Homebrew packages (macOS only)
update_brew_packages() {
    if [[ "$OS" != "macos" ]]; then
        return 0
    fi

    if ! command_exists brew; then
        return 0
    fi

    log_info "Updating Homebrew packages..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if brew upgrade; then
        log_success "Homebrew packages upgraded successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_warning "Some Homebrew packages failed to upgrade"
        SKIPPED_UPDATES=$((SKIPPED_UPDATES + 1))
    fi
}

# Update apt packages (Ubuntu only)
update_apt_packages() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    log_info "Updating apt packages..."
    TOTAL_UPDATES=$((TOTAL_UPDATES + 1))

    if sudo apt update && sudo apt upgrade -y; then
        log_success "apt packages updated successfully"
        SUCCESSFUL_UPDATES=$((SUCCESSFUL_UPDATES + 1))
    else
        log_error "Failed to update apt packages"
        FAILED_UPDATES=$((FAILED_UPDATES + 1))
    fi
}

# Main update function
main() {
    show_banner

    echo "Starting update process..."
    echo ""

    log_info "Detected OS: $OS"
    echo ""

    # Update system packages first
    if [[ "$OS" == "macos" ]]; then
        update_brew
        update_brew_packages
    elif [[ "$OS" == "ubuntu" ]]; then
        update_apt_packages
    fi

    # Update Oh My Zsh and plugins
    update_oh_my_zsh
    update_powerlevel10k
    update_zsh_plugins

    # Update programming languages
    update_python
    update_nodejs

    # Update development tools
    update_claude_code

    # Update Kubernetes tools
    update_kubectx

    # Update other tools
    update_envchain

    # Summary
    echo ""
    echo "======================================"
    echo "  Update Summary"
    echo "======================================"
    echo ""
    echo "Total updates attempted: $TOTAL_UPDATES"
    echo -e "${GREEN}Successful: $SUCCESSFUL_UPDATES${NC}"
    echo -e "${YELLOW}Skipped: $SKIPPED_UPDATES${NC}"
    echo -e "${RED}Failed: $FAILED_UPDATES${NC}"
    echo ""

    if [ $FAILED_UPDATES -gt 0 ]; then
        log_warning "Some updates failed. Check the log for details."
        log_info "Log file: $LOG_FILE"
        exit 1
    else
        log_success "All updates completed successfully!"
        log_info "You may need to restart your terminal for changes to take effect."
        exit 0
    fi
}

# Run main function
main
