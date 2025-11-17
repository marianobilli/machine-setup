#!/usr/bin/env bash

# Machine Setup Script v2.0
# Installs development tools for macOS or Ubuntu

# Note: We don't use 'set -e' to allow the script to continue even if individual steps fail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Source preflight checks
# shellcheck source=lib/preflight.sh
source "${SCRIPT_DIR}/lib/preflight.sh"

# Cleanup function
cleanup() {
    # Stop sudo keep-alive if it's running
    stop_sudo_keepalive
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Default configuration
PROFILE="full"
RUN_PREFLIGHT=true

# Parse command-line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "Machine Setup Script v${SCRIPT_VERSION}"
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                log_info "DRY RUN MODE: No actual changes will be made"
                shift
                ;;
            --verbose)
                VERBOSE=true
                export VERBOSE
                shift
                ;;
            --debug)
                DEBUG=true
                VERBOSE=true
                export DEBUG VERBOSE
                shift
                ;;
            --profile)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    PROFILE="$2"
                    shift 2
                else
                    log_error "Error: --profile requires a profile name"
                    exit 1
                fi
                ;;
            --list-profiles)
                list_profiles
                exit 0
                ;;
            --no-preflight)
                RUN_PREFLIGHT=false
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Install Homebrew (macOS only)
install_brew() {
    # shellcheck source=installers/macos/homebrew.sh
    source "${SCRIPT_DIR}/installers/macos/homebrew.sh"
}

# Install Oh My Zsh with Powerlevel10k
install_oh_my_zsh() {
    # shellcheck source=installers/common/oh-my-zsh.sh
    source "${SCRIPT_DIR}/installers/common/oh-my-zsh.sh"
}

# Install packages from config file
install_packages() {
    # shellcheck source=installers/package-manager.sh
    source "${SCRIPT_DIR}/installers/package-manager.sh"
    install_all_packages
}

# Install Python 3.12 (requires custom setup for PPA on Ubuntu)
install_python() {
    # shellcheck source=installers/common/python.sh
    source "${SCRIPT_DIR}/installers/common/python.sh"
}

# Install Node.js (requires custom setup for NodeSource on Ubuntu)
install_nodejs() {
    # shellcheck source=installers/common/nodejs.sh
    source "${SCRIPT_DIR}/installers/common/nodejs.sh"
}

# Install Claude Code (via npm, not package manager)
install_claude_code() {
    # shellcheck source=installers/common/claude-code.sh
    source "${SCRIPT_DIR}/installers/common/claude-code.sh"
}

# Install kubectx on Ubuntu (requires git clone)
install_kubectx_ubuntu() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    # shellcheck source=installers/ubuntu/kubectx.sh
    source "${SCRIPT_DIR}/installers/ubuntu/kubectx.sh"
}

# Install k9s on Ubuntu (download from GitHub)
install_k9s_ubuntu() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    # shellcheck source=installers/ubuntu/k9s.sh
    source "${SCRIPT_DIR}/installers/ubuntu/k9s.sh"
}

# Install envchain on Ubuntu (build from source)
install_envchain_ubuntu() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    # shellcheck source=installers/ubuntu/envchain.sh
    source "${SCRIPT_DIR}/installers/ubuntu/envchain.sh"
}

# Configure Granted alias
configure_granted() {
    # shellcheck source=installers/common/granted.sh
    source "${SCRIPT_DIR}/installers/common/granted.sh"
    configure_granted
}

# Install and configure gnome-keyring (Ubuntu only)
install_gnome_keyring() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    # shellcheck source=installers/ubuntu/gnome-keyring.sh
    source "${SCRIPT_DIR}/installers/ubuntu/gnome-keyring.sh"
}

# Main installation function
main() {
    # Parse command-line arguments
    parse_arguments "$@"

    # Show banner
    show_banner

    log_info "Profile: $PROFILE"

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE: No changes will be made"
    fi

    echo ""

    # Load versions configuration
    load_versions

    # Load profile configuration
    if ! load_profile "$PROFILE"; then
        log_error "Failed to load profile: $PROFILE"
        log_info "Available profiles:"
        list_profiles
        exit 1
    fi

    # Detect and confirm OS
    DETECTED_OS=$(detect_os)

    if [[ "$DETECTED_OS" == "unknown" ]]; then
        log_warning "Could not automatically detect your OS"
        OS=$(ask_os)
    else
        log_info "Detected OS: $DETECTED_OS"
        if [ "$DRY_RUN" != true ]; then
            read -r -p "Is this correct? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                OS=$DETECTED_OS
            else
                OS=$(ask_os)
            fi
        else
            OS=$DETECTED_OS
        fi
    fi

    export OS

    log_info "Setting up machine for: $OS"
    echo ""

    # Run pre-flight checks
    if [ "$RUN_PREFLIGHT" = true ] && [ "$DRY_RUN" != true ]; then
        if ! run_preflight_checks; then
            log_error "Pre-flight checks failed. Please fix the issues above."
            log_info "To skip pre-flight checks, use: --no-preflight"
            exit 1
        fi
    fi

    # Install Homebrew first if macOS
    if [[ "$OS" == "macos" ]]; then
        install_brew
        echo ""
    fi

    # Install Oh My Zsh with Powerlevel10k theme
    if should_install "oh_my_zsh"; then
        install_oh_my_zsh
        echo ""
    fi

    # Install tools requiring custom setup
    if should_install "python"; then
        install_python
        echo ""
    fi

    if should_install "nodejs"; then
        install_nodejs
        echo ""
    fi

    # Install packages from config file (kubectl, kubectx, k9s, granted, lsof, nmap, envchain, wslu)
    # Note: This handles most packages via brew/apt
    install_packages
    echo ""

    # Install Claude Code (via npm, not in package config)
    if should_install "claude_code"; then
        install_claude_code
        echo ""
    fi

    # Ubuntu-specific custom installers (for packages that can't use apt)
    if should_install "kubectx"; then
        install_kubectx_ubuntu
        echo ""
    fi

    if should_install "k9s"; then
        install_k9s_ubuntu
        echo ""
    fi

    if should_install "envchain"; then
        install_envchain_ubuntu
        echo ""
    fi

    # Configure Granted alias (after package installation)
    if should_install "granted"; then
        configure_granted
        echo ""
    fi

    # Install and configure gnome-keyring (Ubuntu only)
    if should_install "gnome_keyring"; then
        install_gnome_keyring
        echo ""
    fi

    echo "======================================"
    log_success "Setup Complete!"
    echo "======================================"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_info "This was a DRY RUN - no actual changes were made"
        log_info "Run without --dry-run to perform actual installation"
        echo ""
        return 0
    fi

    log_info "Installation log: $LOG_FILE"
    log_info "Please restart your terminal or run: source ~/.zshrc"
    echo ""
    log_info "Next steps:"
    echo "  • Run './scripts/doctor.sh' to verify your installation"
    echo "  • Run 'p10k configure' to customize your Powerlevel10k theme"
    echo "  • Run './scripts/update.sh' to update tools in the future"
    echo ""
    echo "======================================"
    echo "  INSTALLED TOOLS SUMMARY"
    echo "======================================"
    echo ""

    if [[ "$OS" == "macos" ]]; then
        echo -e "${GREEN}Homebrew${NC}"
        echo "  Package manager for macOS"
        echo "  Usage: brew install <package>"
        echo ""
    fi

    echo -e "${GREEN}Oh My Zsh + Powerlevel10k + Enhanced Plugins${NC}"
    echo "  Enhanced Zsh configuration framework with beautiful theme"
    echo "  Theme: Powerlevel10k (run 'p10k configure' to customize)"
    echo "  Location: ~/.oh-my-zsh"
    echo ""
    echo "  Plugins enabled:"
    echo "    • git, docker, kubectl, aws, kubernetes - Tool-specific helpers"
    echo "    • zsh-autosuggestions - Fish-like command suggestions from history"
    echo "    • zsh-syntax-highlighting - Real-time command syntax highlighting"
    echo "    • npm, python - Language-specific aliases and completions"
    echo "    • command-not-found - Suggests packages when command is missing"
    echo "    • colored-man-pages - Colorized man pages"
    echo "    • z - Smart directory jumping (tracks your most used dirs)"
    echo "    • history-substring-search - Enhanced history search (↑/↓ arrows)"
    echo "    • sudo - Press ESC twice to add 'sudo' to previous command"
    echo "    • extract - Universal archive extraction (supports zip, tar, gz, etc.)"
    echo ""

    echo -e "${GREEN}Python 3.12${NC}"
    echo "  Modern Python interpreter"
    echo "  Usage: python3.12 or python3"
    echo ""

    echo -e "${GREEN}Node.js & npm${NC}"
    echo "  JavaScript runtime and package manager"
    echo "  Usage: node <file.js>, npm install <package>"
    echo ""

    echo -e "${GREEN}Claude Code${NC}"
    echo "  Anthropic's AI-powered coding assistant CLI"
    echo "  Usage: claude"
    echo ""

    echo -e "${GREEN}kubectl${NC}"
    echo "  Kubernetes command-line tool for cluster management"
    echo "  Usage: kubectl get pods, kubectl apply -f <file>"
    echo ""

    echo -e "${GREEN}kubectx & kubens${NC}"
    echo "  Quick Kubernetes context and namespace switcher"
    echo "  Usage: kubectx <context>, kubens <namespace>"
    if [[ "$OS" == "ubuntu" ]]; then
        echo "  Location: ~/github/kubectx"
    fi
    echo ""

    echo -e "${GREEN}Granted (assume)${NC}"
    echo "  AWS IAM credential manager for easy role switching"
    echo "  Usage: assume <profile-name>"
    echo ""

    echo -e "${GREEN}k9s${NC}"
    echo "  Terminal UI for managing Kubernetes clusters"
    echo "  Usage: k9s"
    echo ""

    echo -e "${GREEN}envchain${NC}"
    echo "  Secure environment variable management using system keychain"
    echo "  Usage: envchain <namespace> <command>"
    if [[ "$OS" == "ubuntu" ]]; then
        echo "  Location: ~/github/envchain"
    fi
    echo ""

    echo -e "${GREEN}lsof${NC}"
    echo "  List open files and network connections"
    echo "  Usage: lsof -i :8080 (check port), lsof -u username (by user)"
    echo ""

    echo -e "${GREEN}nmap${NC}"
    echo "  Network exploration and security auditing tool"
    echo "  Usage: nmap <target>, nmap -p 1-1000 <target> (port scan)"
    echo ""

    if [[ "$OS" == "ubuntu" ]]; then
        echo -e "${GREEN}wslu${NC}"
        echo "  Utilities for WSL (Windows Subsystem for Linux)"
        echo "  Enables browser launching from WSL terminal"
        echo "  Usage: wslview <url> (open URL in Windows browser)"
        echo ""

        echo -e "${GREEN}gnome-keyring${NC}"
        echo "  Secure credential and secret storage for Linux"
        echo "  Configured for git, granted/assume, and envchain"
        echo "  Auto-starts with your shell session"
        echo "  Usage: Automatic - stores git credentials and AWS profiles securely"
        echo ""
    fi

    echo "======================================"
    echo "For more information on any tool, run:"
    echo "  <tool-name> --help"
    echo "======================================"
}

# Run main function with all arguments
main "$@"
