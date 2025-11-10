# Machine Setup Script

Automated development environment setup script for macOS and Ubuntu. This script installs and configures essential development tools for cloud-native and Kubernetes workflows.

## Features

- **Idempotent**: Safe to run multiple times - won't reinstall existing tools
- **Cross-platform**: Supports both macOS and Ubuntu
- **Interactive**: Detects your OS and confirms before installation
- **Comprehensive**: Installs 8+ essential development tools
- **Organized**: Clones GitHub repositories to `~/github` for easy management

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

### 1. Python 3.12
- **Description**: Modern Python interpreter
- **Usage**: `python3.12` or `python3`
- **Includes**: pip, venv, and development headers

### 2. Node.js & npm
- **Description**: JavaScript runtime and package manager
- **Usage**: `node <file.js>`, `npm install <package>`
- **Version**: Latest LTS

### 3. Claude Code
- **Description**: Anthropic's AI-powered coding assistant CLI
- **Usage**: `claude`
- **Installation**: Via npm global package

### 4. kubectx & kubens
- **Description**: Quick Kubernetes context and namespace switcher
- **Usage**:
  - `kubectx` - List/switch contexts
  - `kubectx <context>` - Switch to context
  - `kubens` - List/switch namespaces
  - `kubens <namespace>` - Switch to namespace
- **Location (Ubuntu)**: `~/github/kubectx`

### 5. kubectl
- **Description**: Kubernetes command-line tool for cluster management
- **Usage**:
  - `kubectl get pods`
  - `kubectl apply -f <file>`
  - `kubectl logs <pod>`
- **Version**: Latest stable (v1.28)

### 6. Granted (assume)
- **Description**: AWS IAM credential manager for easy role switching
- **Usage**: `assume <profile-name>`
- **Features**:
  - Interactive profile selection
  - MFA support
  - Shell alias configured automatically

### 7. k9s
- **Description**: Terminal UI for managing Kubernetes clusters
- **Usage**: `k9s`
- **Features**: Interactive cluster management with keyboard shortcuts

### 8. envchain
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

2. **Verify installations**:
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

3. **Configure tools** as needed:
   - Set up AWS profiles for Granted
   - Configure kubectl contexts
   - Set up envchain namespaces

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