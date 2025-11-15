# Contributing to Machine Setup

Thank you for your interest in contributing to machine-setup! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [CI/CD](#cicd)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing viewpoints and experiences

## Getting Started

### Prerequisites

- Git
- Bash/Zsh shell
- Ubuntu or macOS for testing
- Basic understanding of shell scripting

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/machine-setup.git
   cd machine-setup
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/marianobilli/machine-setup.git
   ```

4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Project Structure

```
machine-setup/
├── setup.sh                    # Main installation script
├── lib/                        # Shared libraries
│   ├── common.sh              # Common utilities
│   └── preflight.sh           # Pre-flight checks
├── config/                     # Configuration files
│   ├── versions.conf          # Tool versions
│   └── profiles/              # Installation profiles
├── scripts/                    # Utility scripts
│   ├── doctor.sh              # Health checks
│   ├── update.sh              # Update tools
│   └── uninstall.sh           # Uninstall tools
├── tests/                      # Test suite
└── .github/                    # GitHub configuration
    └── workflows/ci.yml       # CI/CD pipeline
```

### Making Changes

1. **Keep changes focused**: One feature or fix per PR
2. **Follow existing patterns**: Match the style of surrounding code
3. **Test thoroughly**: Run all tests before submitting
4. **Update documentation**: Keep README and CHANGELOG current

### Common Tasks

#### Adding a New Tool

1. Add install function in `setup.sh`:
   ```bash
   install_new_tool() {
       if command_exists new_tool; then
           log_info "new_tool is already installed"
           return 0
       fi

       log_info "Installing new_tool..."

       if [[ "$OS" == "macos" ]]; then
           brew install new_tool
       elif [[ "$OS" == "ubuntu" ]]; then
           sudo apt install -y new_tool
       fi

       log_success "new_tool installed successfully"
   }
   ```

2. Add to main() function with profile check:
   ```bash
   if should_install "new_tool"; then
       install_new_tool
       echo ""
   fi
   ```

3. Add to profiles (`config/profiles/*.conf`):
   ```bash
   new_tool=true  # or false
   ```

4. Add version to `config/versions.conf`:
   ```bash
   NEW_TOOL_VERSION="1.0.0"
   ```

5. Update README documentation
6. Add to doctor.sh for health checks
7. Add to update.sh for updates
8. Add to uninstall.sh for removal

#### Updating Tool Versions

Edit `config/versions.conf`:
```bash
KUBECTL_VERSION="v1.29"  # Update version
```

#### Creating a New Profile

Create `config/profiles/custom.conf`:
```bash
# Custom Profile Description
oh_my_zsh=true
python=true
nodejs=false
# ... configure all tools
```

## Pull Request Process

### Before Submitting

1. **Update from upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests locally**:
   ```bash
   ./tests/test_setup.sh
   ```

3. **Test dry-run**:
   ```bash
   ./setup.sh --dry-run --profile full
   ```

4. **Verify syntax**:
   ```bash
   bash -n setup.sh
   bash -n lib/*.sh
   bash -n scripts/*.sh
   ```

5. **Run doctor script** (if tools installed):
   ```bash
   ./scripts/doctor.sh
   ```

### Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format
<type>(<scope>): <subject>

# Types
feat: New feature
fix: Bug fix
docs: Documentation only
style: Code style (formatting, no logic change)
refactor: Code refactoring
test: Adding or updating tests
chore: Maintenance tasks

# Examples
feat(kubectl): add kubectl v1.29 support
fix(sudo): improve sudo password caching
docs(readme): update installation instructions
test(preflight): add internet connectivity test
```

### Creating the PR

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR on GitHub**: Visit your fork and click "New Pull Request"

3. **Fill out PR template**: Provide complete information

4. **Wait for CI**: All checks must pass (automatically triggered)

5. **Address review comments**: Make requested changes promptly

### PR Requirements

✅ **Required for merge:**
- All CI checks pass (ShellCheck, tests, validation)
- At least 1 approving review
- All conversations resolved
- CHANGELOG.md updated
- Documentation updated
- No merge conflicts

## Coding Standards

### Shell Script Style

1. **Use bash** for main scripts (not zsh)
2. **Shebang**: `#!/usr/bin/env bash`
3. **Error handling**: Check return codes
4. **Functions**: Use verb-noun format
5. **Variables**: Use descriptive names
6. **Comments**: Explain why, not what

### Example

```bash
# Good
install_python() {
    if command_exists python3.12; then
        log_info "Python 3.12 is already installed"
        return 0
    fi

    log_info "Installing Python 3.12..."

    if [[ "$OS" == "macos" ]]; then
        brew install python@3.12
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y python3.12
    fi

    log_success "Python 3.12 installed successfully"
}

# Bad
inst_py() {
    python3.12 --version > /dev/null 2>&1 && return
    apt install -y python3.12  # No OS check, no logging
}
```

### Logging

Use the provided logging functions:

```bash
log_info "Informational message"
log_success "Success message"
log_warning "Warning message"
log_error "Error message"
log_debug "Debug message (only shown with --debug)"
```

### DRY_RUN Support

For commands that modify the system:

```bash
if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Would install package"
    return 0
fi

# Actual installation
sudo apt install -y package
```

## Testing

### Test Suite

Run the test suite:
```bash
./tests/test_setup.sh
```

Expected output:
```
Total tests: 51
Passed: 51
Failed: 0
Success rate: 100%
```

### Adding Tests

Add to `tests/test_setup.sh`:

```bash
test_new_feature() {
    test_info "Testing new feature..."

    if [ condition ]; then
        test_pass "Feature works correctly"
    else
        test_fail "Feature failed"
    fi
}

# Add to main() function
test_new_feature
```

### Manual Testing

1. **Dry run**:
   ```bash
   ./setup.sh --dry-run --profile minimal
   ./setup.sh --dry-run --profile full
   ./setup.sh --dry-run --profile k8s-dev
   ```

2. **Doctor check**:
   ```bash
   ./scripts/doctor.sh
   ```

3. **Platform testing**: Test on both Ubuntu and macOS if possible

## CI/CD

### Automated Checks

Every PR triggers:
- **ShellCheck Linting**: Static analysis
- **Ubuntu Tests**: 51 tests on Ubuntu
- **macOS Tests**: 51 tests on macOS
- **Config Validation**: Profile and version checks
- **Documentation**: README/CHANGELOG verification

### Required Status Checks

The `All Checks Passed` job must succeed. It depends on all other jobs.

### Viewing CI Results

1. Click **Actions** tab in GitHub
2. Find your workflow run
3. Review job logs for failures
4. Fix issues and push updates

### Local ShellCheck

Install ShellCheck and run locally:

```bash
# Ubuntu
sudo apt install shellcheck

# macOS
brew install shellcheck

# Run
shellcheck setup.sh lib/*.sh scripts/*.sh
```

## Branch Protection

The `main` branch is protected:
- ✅ Requires PR before merging
- ✅ Requires 1 approval
- ✅ Requires all status checks to pass
- ✅ No direct pushes allowed

See [.github/BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md) for setup details.

## Getting Help

- 📖 Read the [README](README.md)
- 🔍 Check [existing issues](https://github.com/marianobilli/machine-setup/issues)
- 💬 Ask questions in issue comments
- 📝 Review [CHANGELOG](CHANGELOG.md) for recent changes

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes (for significant contributions)
- Project documentation (as appropriate)

---

Thank you for contributing to machine-setup! 🎉
