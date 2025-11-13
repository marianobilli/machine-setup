#!/usr/bin/env zsh

# Machine Setup Script
# Installs development tools for macOS or Ubuntu

# Note: We don't use 'set -e' to allow the script to continue even if individual steps fail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Ask user to confirm OS
ask_os() {
    echo "Please select your operating system:"
    echo "1) macOS"
    echo "2) Ubuntu"
    read "choice?Enter your choice (1 or 2): "

    case $choice in
        1)
            echo "macos"
            ;;
        2)
            echo "ubuntu"
            ;;
        *)
            log_error "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
}

# Install Homebrew (macOS only)
install_brew() {
    if command -v brew &> /dev/null; then
        log_info "Homebrew is already installed"
        return 0
    fi

    log_info "Installing Homebrew..."
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

    # Backup existing .zshrc if it exists and wasn't backed up yet
    if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.backup-before-setup ]; then
        cp ~/.zshrc ~/.zshrc.backup-before-setup
        log_info "Backed up existing .zshrc to ~/.zshrc.backup-before-setup"
    fi

    # Ensure required plugins are present (without removing user's existing plugins)
    REQUIRED_PLUGINS=("git" "docker" "kubectl" "aws" "kubernetes")

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

# Main installation function
main() {
    echo "======================================"
    echo "  Machine Setup Script"
    echo "======================================"
    echo ""

    # Detect and confirm OS
    DETECTED_OS=$(detect_os)

    if [[ "$DETECTED_OS" == "unknown" ]]; then
        log_warning "Could not automatically detect your OS"
        OS=$(ask_os)
    else
        log_info "Detected OS: $DETECTED_OS"
        read "confirm?Is this correct? (y/n): "
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            OS=$DETECTED_OS
        else
            OS=$(ask_os)
        fi
    fi

    log_info "Setting up machine for: $OS"
    echo ""

    # Install Homebrew first if macOS
    if [[ "$OS" == "macos" ]]; then
        install_brew
        echo ""
    fi

    # Install Oh My Zsh with Powerlevel10k theme
    install_oh_my_zsh
    echo ""

    # Install all tools
    install_python
    echo ""

    install_nodejs
    echo ""

    install_claude_code
    echo ""

    install_kubectx
    echo ""

    install_kubectl
    echo ""

    install_granted
    echo ""

    install_k9s
    echo ""

    install_envchain
    echo ""

    install_lsof
    echo ""

    install_nmap
    echo ""

    echo "======================================"
    log_info "Setup Complete!"
    echo "======================================"
    echo ""
    log_info "Please restart your terminal or run: source ~/.zshrc"
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

    echo "${GREEN}Oh My Zsh + Powerlevel10k${NC}"
    echo "  Enhanced Zsh configuration framework with beautiful theme"
    echo "  Plugins enabled: git, docker, kubectl, aws, kubernetes"
    echo "  Usage: Run 'p10k configure' to customize your prompt"
    echo "  Location: ~/.oh-my-zsh"
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

    echo "======================================"
    echo "For more information on any tool, run:"
    echo "  <tool-name> --help"
    echo "======================================"
}

# Run main function
main
