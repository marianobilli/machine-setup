# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-11-15

### Added

#### Major Features
- **Installation Profiles**: Three pre-defined profiles (minimal, full, k8s-dev) for different use cases
- **Configuration System**: Tool selection via profile-based configuration files
- **CLI Flags Support**: New command-line flags for enhanced control
  - `--dry-run`: Preview installations without making changes
  - `--verbose`: Show detailed output
  - `--debug`: Show debug information
  - `--profile <name>`: Use specific installation profile
  - `--list-profiles`: List available profiles
  - `--help`: Show help message
  - `--version`: Show script version
- **Pre-flight Checks**: Comprehensive validation before installation
  - Disk space check (requires 2GB minimum)
  - Internet connectivity check
  - Sudo access verification
  - Zsh installation check
  - System architecture detection
  - Conflict detection
- **Enhanced Logging**: Persistent log file at `~/.machine-setup/setup.log`
- **Security Enhancements**: Checksum verification for downloads (SHA256)
- **Version Management**: Centralized version control in `config/versions.conf`

#### New Scripts
- **`scripts/doctor.sh`**: Comprehensive health check and diagnostics
  - Verifies all installed tools
  - Checks configurations
  - Reports success rate
- **`scripts/update.sh`**: Update installed tools to latest versions
  - Updates Oh My Zsh and plugins
  - Updates programming languages
  - Updates Kubernetes tools
  - Updates development tools
- **`scripts/uninstall.sh`**: Safe removal of installed tools
  - Removes all installed tools
  - Preserves backups
  - Cleanup of temporary files

#### Project Structure
- **`lib/`**: Modular library functions
  - `lib/common.sh`: Shared utilities and logging
  - `lib/preflight.sh`: Pre-flight checks
- **`config/`**: Configuration files
  - `config/versions.conf`: Version management
  - `config/profiles/`: Installation profiles
    - `minimal.conf`: Essential tools only
    - `full.conf`: All tools (default)
    - `k8s-dev.conf`: Kubernetes development focus
- **`scripts/`**: Utility scripts (doctor, update, uninstall)
- **`tests/`**: Test suite for automated testing
- **`.github/workflows/`**: GitHub Actions CI/CD

#### Development & Quality Assurance
- **ShellCheck Integration**: `.shellcheckrc` configuration for linting
- **GitHub Actions CI/CD**: Automated testing on push and PR
  - ShellCheck linting
  - Ubuntu testing
  - macOS testing
  - Configuration validation
  - Documentation checks
- **Test Suite**: `tests/test_setup.sh` with comprehensive tests
  - File existence tests
  - Executable permission tests
  - Syntax validation
  - Function availability tests
  - Profile validation
  - Documentation validation

### Changed
- Improved error handling throughout all scripts
- Better output formatting with color-coded messages
- More informative progress indicators
- Enhanced documentation in README

### Technical Improvements
- Modular architecture with reusable components
- Better separation of concerns
- Improved code maintainability
- Comprehensive test coverage
- Automated quality checks

---

## [1.0.0] - 2025-11-14

### Added
- Initial release with core functionality
- Basic installation script for macOS and Ubuntu
- Support for 15+ development tools
- Oh My Zsh with Powerlevel10k theme
- 14 Zsh productivity plugins
- Python 3.12 installation
- Node.js and npm installation
- Claude Code installation
- Kubernetes tools (kubectl, kubectx, k9s)
- AWS tools (granted/assume)
- Environment management (envchain)
- Network tools (lsof, nmap)
- Ubuntu-specific tools (wslu, gnome-keyring)
- Automatic gnome-keyring configuration for Ubuntu
- Git credential helper setup with libsecret
- Idempotent installation (safe to run multiple times)
- Non-destructive configuration updates
- Automatic .zshrc backup

### Features
- Cross-platform support (macOS and Ubuntu)
- Automatic OS detection
- Homebrew installation and management (macOS)
- Package manager integration
- GitHub repository cloning for specific tools
- Comprehensive README documentation
- CLAUDE.md for AI assistant guidance

---

## Version Comparison

### v2.0.0 vs v1.0.0
**Major improvements:**
- Added installation profiles (minimal, full, k8s-dev)
- Added CLI flags (--dry-run, --verbose, --debug, --profile)
- Added pre-flight checks (disk, internet, sudo, etc.)
- Added doctor script for health checks
- Added update script for keeping tools current
- Added uninstall script for safe removal
- Added persistent logging
- Added security features (checksum verification)
- Added CI/CD with GitHub Actions
- Added comprehensive test suite
- Added modular library structure
- Added version management system
- Improved code quality with ShellCheck
- Enhanced documentation

**Breaking changes:**
- None - fully backward compatible
- New features are opt-in via flags

---

## Links
- [Repository](https://github.com/marianobilli/machine-setup)
- [Issues](https://github.com/marianobilli/machine-setup/issues)
