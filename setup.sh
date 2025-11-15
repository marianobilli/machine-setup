#!/usr/bin/env bash

# Machine Setup Script v2.0
# Installs development tools for macOS or Ubuntu

# Note: We don't use 'set -e' to allow the script to continue even if individual steps fail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
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
                shift
                ;;
            --debug)
                DEBUG=true
                VERBOSE=true
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
    if command_exists brew; then
        log_info "Homebrew is already installed"
        return 0
    fi

    log_info "Installing Homebrew..."

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install Homebrew"
        return 0
    fi

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_info "Homebrew installed successfully"
}

# Install Oh My Zsh with Powerlevel10k
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

# Install Python 3.12
install_python() {
    # Check if Python 3.12 is already installed
    if command -v python3.12 &> /dev/null; then
        log_info "Python 3.12 is already installed"
        return 0
    fi

    log_info "Installing Python 3.12..."

    if [[ "$OS" == "macos" ]]; then
        brew install python@3.12
        # Link python3.12 to python3
        brew link python@3.12
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt update
        sudo apt install -y python3.12 python3.12-venv python3.12-dev
        # Set python3.12 as alternative
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
    fi

    log_info "Python 3.12 installed successfully"
}

# Install Node.js and npm
install_nodejs() {
    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        log_info "Node.js is already installed (version: $(node --version))"
        return 0
    fi

    log_info "Installing Node.js and npm..."

    if [[ "$OS" == "macos" ]]; then
        brew install node
    elif [[ "$OS" == "ubuntu" ]]; then
        # Install using NodeSource repository for latest LTS
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    fi

    log_info "Node.js and npm installed successfully"
}

# Install Claude Code
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

# Install kubectx
install_kubectx() {
    # Check if kubectx is already installed
    if command -v kubectx &> /dev/null; then
        log_info "kubectx is already installed"
        return 0
    fi

    log_info "Installing kubectx..."

    if [[ "$OS" == "macos" ]]; then
        brew install kubectx
    elif [[ "$OS" == "ubuntu" ]]; then
        # Create ~/github directory if it doesn't exist
        mkdir -p ~/github

        # Check if already cloned, if so pull latest, otherwise clone
        if [ -d ~/github/kubectx ]; then
            log_info "Updating existing kubectx installation..."
            cd ~/github/kubectx
            git pull
            cd ~
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
    fi

    log_info "kubectx installed successfully"
}

# Install AWS kubectl
install_kubectl() {
    # Check if kubectl is already installed
    if command -v kubectl &> /dev/null; then
        log_info "kubectl is already installed (version: $(kubectl version --client --short 2>/dev/null || echo 'installed'))"
        return 0
    fi

    log_info "Installing kubectl for AWS..."

    if [[ "$OS" == "macos" ]]; then
        brew install kubectl
    elif [[ "$OS" == "ubuntu" ]]; then
        # Install kubectl from official Kubernetes repository
        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl

        # Create keyrings directory if it doesn't exist
        sudo mkdir -p /etc/apt/keyrings

        # Only add key if not already present
        if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
            curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        fi

        # Only add repository if not already present
        if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
            echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
        fi

        sudo apt update
        sudo apt install -y kubectl
    fi

    log_info "kubectl installed successfully"
}

# Install Granted (assume)
install_granted() {
    # Check if granted is already installed
    if command -v granted &> /dev/null; then
        log_info "Granted is already installed"

        # Still check and add alias if missing
        if ! grep -q "alias assume=" ~/.zshrc 2>/dev/null; then
            echo 'alias assume="source assume"' >> ~/.zshrc
        fi

        return 0
    fi

    log_info "Installing Granted (assume)..."

    if [[ "$OS" == "macos" ]]; then
        brew tap common-fate/granted
        brew install granted
    elif [[ "$OS" == "ubuntu" ]]; then
        # Install from GitHub releases
        curl -OL https://releases.commonfate.io/granted/v0.20.5/granted_0.20.5_linux_x86_64.tar.gz
        sudo tar -zxvf granted_0.20.5_linux_x86_64.tar.gz -C /usr/local/bin/
        rm granted_0.20.5_linux_x86_64.tar.gz
    fi

    # Add assume alias to zshrc if not already present
    if ! grep -q "alias assume=" ~/.zshrc 2>/dev/null; then
        echo 'alias assume="source assume"' >> ~/.zshrc
    fi

    log_info "Granted installed successfully"
    log_warning "Please restart your shell or run 'source ~/.zshrc' to use the assume alias"
}

# Install k9s
install_k9s() {
    # Check if k9s is already installed
    if command -v k9s &> /dev/null; then
        log_info "k9s is already installed (version: $(k9s version --short 2>/dev/null || echo 'installed'))"
        return 0
    fi

    log_info "Installing k9s..."

    if [[ "$OS" == "macos" ]]; then
        brew install k9s
    elif [[ "$OS" == "ubuntu" ]]; then
        # Install from GitHub releases
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        curl -OL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
        sudo tar -zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin/ k9s
        rm k9s_Linux_amd64.tar.gz
    fi

    log_info "k9s installed successfully"
}

# Install envchain
install_envchain() {
    # Check if envchain is already installed
    if command -v envchain &> /dev/null; then
        log_info "envchain is already installed"
        return 0
    fi

    log_info "Installing envchain..."

    if [[ "$OS" == "macos" ]]; then
        brew install envchain
    elif [[ "$OS" == "ubuntu" ]]; then
        # Build from source
        sudo apt install -y build-essential libsecret-1-dev libreadline-dev

        # Create ~/github directory if it doesn't exist
        mkdir -p ~/github

        # Clone or update envchain repository
        if [ -d ~/github/envchain ]; then
            log_info "Updating existing envchain repository..."
            cd ~/github/envchain
            git pull
        else
            log_info "Cloning envchain repository..."
            git clone https://github.com/sorah/envchain.git ~/github/envchain
            cd ~/github/envchain
        fi

        # Build and install
        make
        sudo make install
        cd ~
    fi

    log_info "envchain installed successfully"
}

# Install lsof
install_lsof() {
    # Check if lsof is already installed
    if command -v lsof &> /dev/null; then
        log_info "lsof is already installed"
        return 0
    fi

    log_info "Installing lsof..."

    if [[ "$OS" == "macos" ]]; then
        # lsof comes pre-installed on macOS
        log_info "lsof is typically pre-installed on macOS"
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y lsof
    fi

    log_info "lsof installed successfully"
}

# Install nmap
install_nmap() {
    # Check if nmap is already installed
    if command -v nmap &> /dev/null; then
        log_info "nmap is already installed (version: $(nmap --version | head -n 1))"
        return 0
    fi

    log_info "Installing nmap..."

    if [[ "$OS" == "macos" ]]; then
        brew install nmap
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y nmap
    fi

    log_info "nmap installed successfully"
}

# Install wslu (for Ubuntu WSL)
install_wslu() {
    # Only install on Ubuntu (typically for WSL)
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    # Check if wslu is already installed
    if command -v wslview &> /dev/null; then
        log_info "wslu is already installed"
        return 0
    fi

    log_info "Installing wslu (for WSL browser integration)..."

    sudo apt update
    sudo apt install -y wslu

    log_info "wslu installed successfully"
}

# Install and configure gnome-keyring
install_gnome_keyring() {
    # Only install on Ubuntu
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

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
                cd /usr/share/doc/git/contrib/credential/libsecret
                sudo make
                cd ~
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
            read "confirm?Is this correct? (y/n): "
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
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

    # Install all tools based on profile
    if should_install "python"; then
        install_python
        echo ""
    fi

    if should_install "nodejs"; then
        install_nodejs
        echo ""
    fi

    if should_install "claude_code"; then
        install_claude_code
        echo ""
    fi

    if should_install "kubectx"; then
        install_kubectx
        echo ""
    fi

    if should_install "kubectl"; then
        install_kubectl
        echo ""
    fi

    if should_install "granted"; then
        install_granted
        echo ""
    fi

    if should_install "k9s"; then
        install_k9s
        echo ""
    fi

    if should_install "envchain"; then
        install_envchain
        echo ""
    fi

    if should_install "lsof"; then
        install_lsof
        echo ""
    fi

    if should_install "nmap"; then
        install_nmap
        echo ""
    fi

    if should_install "wslu"; then
        install_wslu
        echo ""
    fi

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
        echo "${GREEN}Homebrew${NC}"
        echo "  Package manager for macOS"
        echo "  Usage: brew install <package>"
        echo ""
    fi

    echo "${GREEN}Oh My Zsh + Powerlevel10k + Enhanced Plugins${NC}"
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

    echo "${GREEN}Python 3.12${NC}"
    echo "  Modern Python interpreter"
    echo "  Usage: python3.12 or python3"
    echo ""

    echo "${GREEN}Node.js & npm${NC}"
    echo "  JavaScript runtime and package manager"
    echo "  Usage: node <file.js>, npm install <package>"
    echo ""

    echo "${GREEN}Claude Code${NC}"
    echo "  Anthropic's AI-powered coding assistant CLI"
    echo "  Usage: claude"
    echo ""

    echo "${GREEN}kubectl${NC}"
    echo "  Kubernetes command-line tool for cluster management"
    echo "  Usage: kubectl get pods, kubectl apply -f <file>"
    echo ""

    echo "${GREEN}kubectx & kubens${NC}"
    echo "  Quick Kubernetes context and namespace switcher"
    echo "  Usage: kubectx <context>, kubens <namespace>"
    if [[ "$OS" == "ubuntu" ]]; then
        echo "  Location: ~/github/kubectx"
    fi
    echo ""

    echo "${GREEN}Granted (assume)${NC}"
    echo "  AWS IAM credential manager for easy role switching"
    echo "  Usage: assume <profile-name>"
    echo ""

    echo "${GREEN}k9s${NC}"
    echo "  Terminal UI for managing Kubernetes clusters"
    echo "  Usage: k9s"
    echo ""

    echo "${GREEN}envchain${NC}"
    echo "  Secure environment variable management using system keychain"
    echo "  Usage: envchain <namespace> <command>"
    if [[ "$OS" == "ubuntu" ]]; then
        echo "  Location: ~/github/envchain"
    fi
    echo ""

    echo "${GREEN}lsof${NC}"
    echo "  List open files and network connections"
    echo "  Usage: lsof -i :8080 (check port), lsof -u username (by user)"
    echo ""

    echo "${GREEN}nmap${NC}"
    echo "  Network exploration and security auditing tool"
    echo "  Usage: nmap <target>, nmap -p 1-1000 <target> (port scan)"
    echo ""

    if [[ "$OS" == "ubuntu" ]]; then
        echo "${GREEN}wslu${NC}"
        echo "  Utilities for WSL (Windows Subsystem for Linux)"
        echo "  Enables browser launching from WSL terminal"
        echo "  Usage: wslview <url> (open URL in Windows browser)"
        echo ""

        echo "${GREEN}gnome-keyring${NC}"
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
