# Machine Setup Script

Automated development environment setup script for macOS and Ubuntu. This script installs and configures essential development tools for cloud-native and Kubernetes workflows.

## Features

- **Idempotent**: Safe to run multiple times - won't reinstall existing tools
- **Cross-platform**: Supports both macOS and Ubuntu
- **Interactive**: Detects your OS and confirms before installation
- **Comprehensive**: Installs 9+ essential development tools
- **Beautiful Shell**: Oh My Zsh with Powerlevel10k theme and productivity plugins
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

### 1. Oh My Zsh + Powerlevel10k
- **Description**: Enhanced Zsh configuration framework with a beautiful, customizable theme
- **Features**:
  - Powerlevel10k theme for a modern, fast prompt (installed but not forced)
  - Ensures required plugins are present: git, docker, kubectl, aws, kubernetes
  - **Non-invasive**: Preserves existing Powerlevel10k configuration if already customized
  - **Additive**: Only adds missing plugins, keeps your existing ones
  - Automatic .zshrc backup before first configuration
- **Usage**:
  - Run `p10k configure` to customize your prompt appearance (if using Powerlevel10k)
  - Enjoy enhanced autocomplete and syntax highlighting
- **Location**: `~/.oh-my-zsh`
- **Plugins** (automatically ensured):
  - **git**: Git command aliases and information
  - **docker**: Docker command completion
  - **kubectl**: Kubernetes kubectl completion and aliases
  - **aws**: AWS CLI completion
  - **kubernetes**: Enhanced Kubernetes context/namespace display
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
   ```

4. **Configure tools** as needed:
   - Set up AWS profiles for Granted
   - Configure kubectl contexts
   - Set up envchain namespaces

5. **Note about .zshrc and Oh My Zsh**:
   - Your original `.zshrc` is backed up to `~/.zshrc.backup-before-setup` (first run only)
   - The script ensures these plugins are present: git, docker, kubectl, aws, kubernetes
   - Existing plugins and configurations are preserved
   - If Powerlevel10k is already installed and configured, your customization remains unchanged

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