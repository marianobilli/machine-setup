# Machine Setup Script v2.0

Automated development environment setup script for macOS and Ubuntu. This script installs and configures essential development tools for cloud-native and Kubernetes workflows.

## ✨ New in v2.0

- **🎯 Installation Profiles**: Choose minimal, full, or k8s-dev profiles
- **🔍 Pre-flight Checks**: Validates system before installation
- **📊 Health Diagnostics**: `doctor.sh` script checks your setup
- **🔄 Update Management**: `update.sh` keeps tools current
- **🗑️ Safe Uninstall**: `uninstall.sh` cleanly removes tools
- **📝 Enhanced Logging**: Persistent logs at `~/.machine-setup/setup.log`
- **🔒 Security**: Checksum verification for downloads
- **🧪 CI/CD**: Automated testing with GitHub Actions
- **⚙️ CLI Flags**: `--dry-run`, `--verbose`, `--debug`, `--profile`

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
- **Profiles**: Choose installation profiles based on your needs
- **Validated**: Pre-flight checks ensure system requirements are met

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
1. Run pre-flight checks (disk space, internet, permissions)
2. Detect your operating system
3. Ask for confirmation
4. Install all tools automatically
5. Display a summary of installed tools

## Usage

### Command-Line Options

```bash
# Show help
./setup.sh --help

# Show version
./setup.sh --version

# Preview what would be installed (dry-run)
./setup.sh --dry-run

# Use a specific profile
./setup.sh --profile minimal       # Essential tools only
./setup.sh --profile k8s-dev       # Kubernetes development
./setup.sh --profile full          # All tools (default)

# List available profiles
./setup.sh --list-profiles

# Verbose output
./setup.sh --verbose

# Debug mode
./setup.sh --debug

# Combine options
./setup.sh --dry-run --verbose --profile minimal
```

### Installation Profiles

The script supports three installation profiles:

#### **Minimal** (`--profile minimal`)
Essential development tools only:
- Oh My Zsh + Powerlevel10k
- Python 3.12
- Node.js & npm
- Claude Code
- lsof

Perfect for: Basic development environments, limited disk space

#### **Full** (default)
All available tools:
- Everything in Minimal, plus:
- Kubernetes tools (kubectl, kubectx, k9s)
- AWS tools (granted/assume)
- Environment management (envchain)
- Network tools (nmap)
- Security tools (gnome-keyring on Ubuntu)

Perfect for: Cloud-native and Kubernetes development

#### **K8s-Dev** (`--profile k8s-dev`)
Optimized for Kubernetes developers:
- Same as Full profile
- Specifically tuned for cloud-native workflows

Perfect for: DevOps engineers, SREs, Kubernetes developers

## Utility Scripts

### Doctor - Health Check

Diagnose your installation and verify all tools are working:

```bash
./scripts/doctor.sh
```

The doctor script:
- Checks if all tools are installed
- Verifies configurations
- Tests Oh My Zsh and plugins
- Validates git credential helper
- Reports success rate

### Update - Keep Tools Current

Update all installed tools to their latest versions:

```bash
./scripts/update.sh
```

The update script:
- Updates Oh My Zsh and plugins
- Updates Homebrew packages (macOS)
- Updates apt packages (Ubuntu)
- Updates global npm packages
- Updates Python pip
- Updates tools from GitHub repositories

### Uninstall - Clean Removal

Safely remove installed tools:

```bash
./scripts/uninstall.sh
```

The uninstall script:
- Removes all installed tools
- Preserves Oh My Zsh (optional)
- Restores .zshrc backup
- Cleans up log files
- Removes temporary directories

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
├── setup.sh                    # Main setup script
├── README.md                   # This file
├── CLAUDE.md                   # Claude Code project guidance
├── CHANGELOG.md                # Version history
├── .shellcheckrc               # ShellCheck configuration
│
├── lib/                        # Shared libraries
│   ├── common.sh              # Common utilities and logging
│   └── preflight.sh           # Pre-flight checks
│
├── config/                     # Configuration files
│   ├── versions.conf          # Tool version management
│   └── profiles/              # Installation profiles
│       ├── minimal.conf       # Minimal profile
│       ├── full.conf          # Full profile (default)
│       └── k8s-dev.conf       # Kubernetes dev profile
│
├── scripts/                    # Utility scripts
│   ├── doctor.sh              # Health check and diagnostics
│   ├── update.sh              # Update installed tools
│   └── uninstall.sh           # Uninstall tools
│
├── tests/                      # Test suite
│   └── test_setup.sh          # Automated tests
│
└── .github/                    # GitHub configuration
    └── workflows/
        └── ci.yml             # CI/CD pipeline
```

## Logs and Debugging

### Log Files

All operations are logged to: `~/.machine-setup/setup.log`

View logs:
```bash
cat ~/.machine-setup/setup.log
tail -f ~/.machine-setup/setup.log  # Follow logs in real-time
```

### Debug Mode

Enable detailed output:
```bash
./setup.sh --debug
./setup.sh --verbose
```

## Customization

### Creating Custom Profiles

Create a new profile in `config/profiles/my-profile.conf`:

```bash
# My Custom Profile
oh_my_zsh=true
python=true
nodejs=true
kubectl=false
# ... set other tools
```

Use your profile:
```bash
./setup.sh --profile my-profile
```

### Modifying Tool Versions

Edit `config/versions.conf` to change tool versions:

```bash
PYTHON_VERSION="3.12"
KUBECTL_VERSION="v1.28"
GRANTED_VERSION="0.20.5"
```

### Adding New Tools

1. Create a new install function in `setup.sh`
2. Add it to the `main()` function
3. Update the configuration profiles
4. Add version info to `config/versions.conf` (if applicable)

## Troubleshooting

### Using the Doctor Script

Before diving into manual troubleshooting, run the doctor script:

```bash
./scripts/doctor.sh
```

This will diagnose common issues and tell you exactly what's wrong.

### Check the Logs

View detailed logs:
```bash
cat ~/.machine-setup/setup.log
```

### Pre-flight Check Failures

If pre-flight checks fail:

**Disk Space:**
```bash
df -h ~  # Check available space
# Free up space or use --profile minimal
```

**Internet Connectivity:**
```bash
curl -I https://github.com  # Test connection
# Check your network settings
```

**Zsh Not Installed:**
```bash
# Ubuntu
sudo apt install zsh

# macOS
brew install zsh  # or use built-in zsh
```

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
dbus-send --session --print-reply --dest=org.freedesktop.DBus / org.freedesktop.DBus.ListNames | grep -i secret
```

Manually start the daemon (with proper D-Bus support):
```bash
# Ensure D-Bus session is available
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Start gnome-keyring with all components
eval $(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh 2>/dev/null)
export GNOME_KEYRING_CONTROL
export SSH_AUTH_SOCK
export GNOME_KEYRING_PID
```

If you get "Timeout was reached" errors with envchain or assume:
```bash
# Install dbus-x11 if missing
sudo apt install -y dbus-x11

# Restart keyring daemon
pkill -f gnome-keyring-daemon
eval $(dbus-launch --sh-syntax)
eval $(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh 2>/dev/null)
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