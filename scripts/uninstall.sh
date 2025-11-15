#!/usr/bin/env bash

# Uninstall script - Remove tools installed by machine setup
# This script carefully removes installed tools and restores backups

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Detect OS
OS=$(detect_os)

# Uninstall confirmation
confirm_uninstall() {
    echo "======================================"
    echo "  Machine Setup - Uninstall"
    echo "======================================"
    echo ""
    log_warning "This script will remove tools installed by machine-setup."
    log_warning "This operation can be destructive!"
    echo ""
    echo "The following will be removed:"
    echo "  - Programming languages (Python 3.12, Node.js)"
    echo "  - Kubernetes tools (kubectl, kubectx, k9s)"
    echo "  - AWS tools (granted)"
    echo "  - Development tools (Claude Code, envchain)"
    echo "  - Network tools (nmap)"
    echo ""
    echo "The following will NOT be removed:"
    echo "  - Oh My Zsh (use 'uninstall_oh_my_zsh' to remove)"
    echo "  - Homebrew (macOS)"
    echo "  - System packages (lsof, gnome-keyring)"
    echo ""

    read -r -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Uninstall cancelled."
        exit 0
    fi
}

# Restore .zshrc backup
restore_zshrc() {
    if [ -f "$HOME/.zshrc.backup-before-setup" ]; then
        log_info "Restoring .zshrc backup..."
        cp "$HOME/.zshrc.backup-before-setup" "$HOME/.zshrc"
        log_success ".zshrc restored from backup"
    else
        log_warning "No .zshrc backup found, skipping restore"
    fi
}

# Uninstall Python 3.12
uninstall_python() {
    if ! command_exists python3.12; then
        return 0
    fi

    log_info "Uninstalling Python 3.12..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall python@3.12 || log_warning "Failed to uninstall Python 3.12"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt remove -y python3.12 python3.12-venv python3.12-dev || log_warning "Failed to uninstall Python 3.12"
    fi

    log_success "Python 3.12 uninstalled"
}

# Uninstall Node.js
uninstall_nodejs() {
    if ! command_exists node; then
        return 0
    fi

    log_info "Uninstalling Node.js..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall node || log_warning "Failed to uninstall Node.js"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt remove -y nodejs || log_warning "Failed to uninstall Node.js"
        # Remove NodeSource repository
        sudo rm -f /etc/apt/sources.list.d/nodesource.list
    fi

    log_success "Node.js uninstalled"
}

# Uninstall Claude Code
uninstall_claude_code() {
    if ! command_exists claude; then
        return 0
    fi

    log_info "Uninstalling Claude Code..."

    sudo npm uninstall -g @anthropic-ai/claude-code || log_warning "Failed to uninstall Claude Code"

    log_success "Claude Code uninstalled"
}

# Uninstall kubectx
uninstall_kubectx() {
    if ! command_exists kubectx; then
        return 0
    fi

    log_info "Uninstalling kubectx..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall kubectx || log_warning "Failed to uninstall kubectx"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo rm -f /usr/local/bin/kubectx
        sudo rm -f /usr/local/bin/kubens
        rm -rf "$HOME/github/kubectx"
    fi

    log_success "kubectx uninstalled"
}

# Uninstall kubectl
uninstall_kubectl() {
    if ! command_exists kubectl; then
        return 0
    fi

    log_info "Uninstalling kubectl..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall kubectl || log_warning "Failed to uninstall kubectl"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt remove -y kubectl || log_warning "Failed to uninstall kubectl"
        # Remove Kubernetes repository
        sudo rm -f /etc/apt/sources.list.d/kubernetes.list
        sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    fi

    log_success "kubectl uninstalled"
}

# Uninstall Granted
uninstall_granted() {
    if ! command_exists granted; then
        return 0
    fi

    log_info "Uninstalling Granted..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall granted || log_warning "Failed to uninstall granted"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo rm -f /usr/local/bin/granted
        sudo rm -f /usr/local/bin/assume
    fi

    # Remove alias from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        sed -i.bak '/alias assume=/d' "$HOME/.zshrc"
    fi

    log_success "Granted uninstalled"
}

# Uninstall k9s
uninstall_k9s() {
    if ! command_exists k9s; then
        return 0
    fi

    log_info "Uninstalling k9s..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall k9s || log_warning "Failed to uninstall k9s"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo rm -f /usr/local/bin/k9s
    fi

    log_success "k9s uninstalled"
}

# Uninstall envchain
uninstall_envchain() {
    if ! command_exists envchain; then
        return 0
    fi

    log_info "Uninstalling envchain..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall envchain || log_warning "Failed to uninstall envchain"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo rm -f /usr/local/bin/envchain
        rm -rf "$HOME/github/envchain"
    fi

    log_success "envchain uninstalled"
}

# Uninstall nmap
uninstall_nmap() {
    if ! command_exists nmap; then
        return 0
    fi

    log_info "Uninstalling nmap..."

    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew uninstall nmap || log_warning "Failed to uninstall nmap"
        fi
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt remove -y nmap || log_warning "Failed to uninstall nmap"
    fi

    log_success "nmap uninstalled"
}

# Uninstall wslu (Ubuntu only)
uninstall_wslu() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    if ! command_exists wslview; then
        return 0
    fi

    log_info "Uninstalling wslu..."

    sudo apt remove -y wslu || log_warning "Failed to uninstall wslu"

    log_success "wslu uninstalled"
}

# Clean up GitHub directory
cleanup_github_dir() {
    if [ -d "$HOME/github" ]; then
        # Only remove if it's empty or only contains setup-related repos
        local repo_count=$(find "$HOME/github" -mindepth 1 -maxdepth 1 -type d | wc -l)

        if [ "$repo_count" -eq 0 ]; then
            log_info "Removing empty ~/github directory..."
            rmdir "$HOME/github"
        else
            log_info "~/github directory contains other repositories, keeping it"
        fi
    fi
}

# Clean up log files
cleanup_logs() {
    log_info "Cleaning up log files..."

    if [ -d "$HOME/.machine-setup" ]; then
        rm -rf "$HOME/.machine-setup"
        log_success "Log files removed"
    fi
}

# Main uninstall function
main() {
    show_banner

    confirm_uninstall

    echo ""
    log_info "Starting uninstall process..."
    log_info "Detected OS: $OS"
    echo ""

    # Uninstall all tools
    uninstall_claude_code
    uninstall_k9s
    uninstall_granted
    uninstall_kubectl
    uninstall_kubectx
    uninstall_envchain
    uninstall_nmap
    uninstall_wslu
    uninstall_nodejs
    uninstall_python

    # Cleanup
    cleanup_github_dir
    cleanup_logs

    echo ""
    log_info "Uninstall complete!"
    echo ""
    log_warning "NOTE: The following were NOT removed:"
    echo "  - Oh My Zsh (run: uninstall_oh_my_zsh)"
    echo "  - Homebrew (macOS)"
    echo "  - System packages (lsof, gnome-keyring)"
    echo ""
    log_info "To restore your original .zshrc, run:"
    echo "  cp ~/.zshrc.backup-before-setup ~/.zshrc"
    echo ""
}

# Run main function
main
