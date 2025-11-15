# Machine Setup Script

Automated development environment setup script for macOS and Ubuntu. This script installs and configures essential development tools for cloud-native and Kubernetes workflows.

## Features

- **Idempotent**: Safe to run multiple times - won't reinstall existing tools
- **Cross-platform**: Supports both macOS and Ubuntu
- **Interactive**: Detects your OS and confirms before installation
- **Comprehensive**: Installs 15+ essential development tools
- **Beautiful Shell**: Oh My Zsh with Powerlevel10k theme and 14 productivity plugins
- **Secure**: Configures gnome-keyring for secure credential storage (Ubuntu)
- **WSL Optimized**: Includes wslu for browser integration from WSL terminal (Ubuntu)
- **Organized**: Clones GitHub repositories to `~/github` for easy management
- **Safe**: Backs up existing `.zshrc` before making changes

## Supported Operating Systems

- macOS (via Homebrew)
- Ubuntu (24.04 and similar versions)

## Prerequisites

- **macOS**: Xcode Command Line Tools (script will prompt if needed)
- **Ubuntu**: `sudo` access and internet connection
- **Both**: `zsh` shell (script is written for zsh)

## Quick Start

```bash
# Clone this repository
git clone https://github.com/marianobilli/machine-setup.git
cd machine-setup

# Make the script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

The script will:
1. Detect your operating system
2. Ask for confirmation
3. Install all tools automatically
4. Display a summary of installed tools

## Installed Tools

### 0. Homebrew (macOS only)
- **Description**: Package manager for macOS
- **Usage**: `brew install <package>`

### 1. Oh My Zsh + Powerlevel10k + Enhanced Plugins
- **Description**: Enhanced Zsh configuration framework with a beautiful, customizable theme and comprehensive plugin suite
- **Features**:
  - Powerlevel10k theme for a modern, fast prompt (installed but not forced)
  - 14 productivity plugins installed and configured automatically
  - **Non-invasive**: Preserves existing Powerlevel10k configuration if already customized
  - **Additive**: Only adds missing plugins, keeps your existing ones
  - Automatic .zshrc backup before first configuration
- **Usage**:
  - Run `p10k configure` to customize your prompt appearance (if using Powerlevel10k)
  - Enjoy enhanced autocomplete, syntax highlighting, and smart suggestions
- **Location**: `~/.oh-my-zsh`
- **Plugins** (14 total, automatically ensured):
  - **git**: Git command aliases and information
  - **docker**: Docker command completion
  - **kubectl**: Kubernetes kubectl completion and aliases
  - **aws**: AWS CLI completion
  - **kubernetes**: Enhanced Kubernetes context/namespace display
  - **zsh-autosuggestions**: Fish-like command suggestions from history (external plugin)
  - **zsh-syntax-highlighting**: Real-time command syntax validation (external plugin)
  - **npm**: npm command aliases and completions
  - **python**: Python-specific helper commands
  - **command-not-found**: Suggests packages when command is missing
  - **colored-man-pages**: Colorizes man pages for better readability
  - **z**: Smart directory jumping based on frecency
  - **history-substring-search**: Enhanced history search with arrow keys
  - **sudo**: Press ESC twice to add 'sudo' to previous command
  - **extract**: Universal archive extraction command
- **Note**: If you already have Powerlevel10k or other plugins configured, this script will only add what's missing without overwriting your setup

### 2. Python 3.12
- **Description**: Modern Python interpreter
- **Usage**: `python3.12` or `python3`
- **Includes**: pip, venv, and development headers

### 3. Node.js & npm
- **Description**: JavaScript runtime and package manager
- **Usage**: `node <file.js>`, `npm install <package>`
- **Version**: Latest LTS

### 4. Claude Code
- **Description**: Anthropic's AI-powered coding assistant CLI
- **Usage**: `claude`
- **Installation**: Via npm global package

### 5. kubectx & kubens
- **Description**: Quick Kubernetes context and namespace switcher
- **Usage**:
  - `kubectx` - List/switch contexts
  - `kubectx <context>` - Switch to context
  - `kubens` - List/switch namespaces
  - `kubens <namespace>` - Switch to namespace
- **Location (Ubuntu)**: `~/github/kubectx`

### 6. kubectl
- **Description**: Kubernetes command-line tool for cluster management
- **Usage**:
  - `kubectl get pods`
  - `kubectl apply -f <file>`
  - `kubectl logs <pod>`
- **Version**: Latest stable (v1.28)

### 7. Granted (assume)
- **Description**: AWS IAM credential manager for easy role switching
- **Usage**: `assume <profile-name>`
- **Features**:
  - Interactive profile selection
  - MFA support
  - Shell alias configured automatically

### 8. k9s
- **Description**: Terminal UI for managing Kubernetes clusters
- **Usage**: `k9s`
- **Features**: Interactive cluster management with keyboard shortcuts

### 9. envchain
- **Description**: Secure environment variable management using system keychain
- **Usage**:
  - `envchain <namespace> <command>`
  - `envchain --set <namespace> <key>`
- **Location (Ubuntu)**: `~/github/envchain`
- **Note**: On Ubuntu, uses gnome-keyring via libsecret for secure storage

### 10. lsof
- **Description**: List open files and network connections
- **Usage**:
  - `lsof -i :8080` - Check what's using port 8080
  - `lsof -u username` - List files opened by user
  - `lsof -c process` - List files opened by process
- **Platforms**: macOS (pre-installed), Ubuntu

### 11. nmap
- **Description**: Network exploration and security auditing tool
- **Usage**:
  - `nmap <target>` - Scan target host
  - `nmap -p 1-1000 <target>` - Scan specific port range
  - `nmap -sV <target>` - Detect service versions
- **Platforms**: macOS, Ubuntu

### 12. wslu (Ubuntu WSL only)
- **Description**: Utilities for WSL (Windows Subsystem for Linux)
- **Features**: Enables opening URLs in Windows browser from WSL terminal
- **Usage**:
  - `wslview <url>` - Open URL in Windows default browser
  - `wslview <file>` - Open file with Windows default application
- **Use Case**: Essential for WSL users who need to open links from terminal

### 13. gnome-keyring (Ubuntu only)
- **Description**: Secure credential and secret storage daemon for Linux
- **Features**:
  - Auto-starts with your shell session
  - Provides secure storage for credentials and secrets
  - Integrated with multiple tools for seamless authentication
- **Automatic Integrations**:
  - **Git**: Configured to store Git credentials securely via `git-credential-libsecret`
  - **Granted/assume**: Stores AWS profile credentials securely via libsecret
  - **envchain**: Stores environment variables securely via libsecret
  - **SSH**: SSH agent integration for key management
- **Configuration**:
  - Daemon starts automatically in `.zshrc`
  - Git credential helper built and configured automatically
  - No manual setup required - works out of the box
- **Usage**: Transparent - credentials are stored and retrieved automatically
- **Benefits**:
  - No plaintext credentials in config files
  - Credentials persist across sessions
  - Protected by system keyring password

## Post-Installation

After the script completes:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Configure Powerlevel10k** (first time only):
   ```bash
   p10k configure
   ```
   This will launch an interactive wizard to customize your prompt appearance.

3. **Verify installations**:
   ```bash
   python3.12 --version
   node --version
   claude --help
   kubectl version --client
   kubectx
   assume --help
   k9s version
   envchain --help
   lsof -v
   nmap --version
   ```

   **Ubuntu WSL users** - verify additional tools:
   ```bash
   wslview --help
   echo $GNOME_KEYRING_CONTROL  # Should show a path if keyring is running
   git config --global credential.helper  # Should show libsecret path
   ```

4. **Configure tools** as needed:
   - Set up AWS profiles for Granted
   - Configure kubectl contexts
   - Set up envchain namespaces

5. **Ubuntu users - gnome-keyring first-time setup**:

   When you first use git, granted/assume, or envchain, you may be prompted to unlock the keyring:

   ```bash
   # First git push/pull will prompt for credentials
   git clone https://github.com/yourrepo/example.git
   # Enter your credentials - they'll be saved to gnome-keyring

   # First time using granted/assume
   assume my-aws-profile
   # Credentials are stored in gnome-keyring automatically

   # First time using envchain
   envchain --set myapp API_KEY
   # Secret is stored in gnome-keyring
   ```

   After the first authentication, credentials are retrieved automatically from gnome-keyring.

6. **Note about .zshrc and Oh My Zsh**:
   - Your original `.zshrc` is backed up to `~/.zshrc.backup-before-setup` (first run only)
   - The script ensures 14 productivity plugins are present (see plugin list above)
   - Existing plugins and configurations are preserved
   - If Powerlevel10k is already installed and configured, your customization remains unchanged
   - Ubuntu users: gnome-keyring daemon auto-start is added to `.zshrc`

## Script Behavior

### Idempotency
The script checks if each tool is already installed before attempting installation. You can safely run it multiple times.

### GitHub Repositories
Two tools are cloned from GitHub (Ubuntu only):
- `kubectx` → `~/github/kubectx`
- `envchain` → `~/github/envchain`

On subsequent runs, these repositories are updated via `git pull`.

### Error Handling
The script continues execution even if individual installations fail, allowing you to install as many tools as possible in one run.

## Directory Structure

```
machine-setup/
├── setup.sh          # Main setup script
├── README.md         # This file
└── CLAUDE.md         # Claude Code project guidance
```

## Customization

To modify the script:

1. Edit `setup.sh`
2. Each tool has its own `install_<tool>()` function
3. Tools are called sequentially in the `main()` function
4. Add new tools by creating a new install function and calling it in `main()`

## Troubleshooting

### Permission Denied
```bash
chmod +x setup.sh
```

### Script fails on Ubuntu
Ensure you have sudo access:
```bash
sudo -v
```

### Node.js repository issues
The script adds the NodeSource repository. If it fails, manually remove:
```bash
sudo rm /etc/apt/sources.list.d/nodesource.list
```

### envchain compilation fails
Install missing dependencies:
```bash
sudo apt install -y build-essential libsecret-1-dev libreadline-dev
```

### gnome-keyring not starting (Ubuntu)
Check if the daemon is running:
```bash
echo $GNOME_KEYRING_CONTROL
ps aux | grep gnome-keyring
```

Manually start the daemon:
```bash
eval $(gnome-keyring-daemon --start --components=secrets,ssh)
export GNOME_KEYRING_CONTROL
export SSH_AUTH_SOCK
```

### git-credential-libsecret build fails
Ensure development libraries are installed:
```bash
sudo apt install -y libglib2.0-dev libsecret-1-dev git
cd /usr/share/doc/git/contrib/credential/libsecret
sudo make
```

### granted/assume not storing credentials in keyring
Verify libsecret is installed:
```bash
dpkg -l | grep libsecret
```

If missing:
```bash
sudo apt install -y libsecret-1-0 libsecret-1-dev
```

## Contributing

Feel free to submit issues or pull requests to improve this setup script.

## License

This project is provided as-is for personal use.

## Author

Mariano Billi

## Acknowledgments

- [kubectx](https://github.com/ahmetb/kubectx) by ahmetb
- [envchain](https://github.com/sorah/envchain) by sorah
- [k9s](https://github.com/derailed/k9s) by derailed
- [granted](https://github.com/common-fate/granted) by Common Fate