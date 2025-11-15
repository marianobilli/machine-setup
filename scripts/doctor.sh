#!/usr/bin/env bash

# Doctor script - Diagnose machine setup installation
# Checks if all tools are properly installed and configured

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Detect OS
OS=$(detect_os)

# Health check results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Check individual tool
check_tool() {
    local tool_name="$1"
    local command_name="${2:-$1}"
    local version_arg="${3:---version}"
    local required="${4:-optional}"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if command_exists "$command_name"; then
        local version_output
        if version_output=$("$command_name" "$version_arg" 2>&1 | head -n 1); then
            log_success "$tool_name is installed: $version_output"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            return 0
        else
            log_success "$tool_name is installed"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            return 0
        fi
    else
        if [ "$required" = "required" ]; then
            log_error "$tool_name is NOT installed (required)"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            return 1
        else
            log_warning "$tool_name is NOT installed (optional)"
            WARNINGS=$((WARNINGS + 1))
            return 1
        fi
    fi
}

# Check directory
check_directory() {
    local name="$1"
    local path="$2"
    local required="${3:-optional}"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -d "$path" ]; then
        log_success "$name exists: $path"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$required" = "required" ]; then
            log_error "$name NOT found: $path (required)"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            return 1
        else
            log_warning "$name NOT found: $path (optional)"
            WARNINGS=$((WARNINGS + 1))
            return 1
        fi
    fi
}

# Check file
check_file() {
    local name="$1"
    local path="$2"
    local required="${3:-optional}"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -f "$path" ]; then
        log_success "$name exists: $path"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$required" = "required" ]; then
            log_error "$name NOT found: $path (required)"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            return 1
        else
            log_warning "$name NOT found: $path (optional)"
            WARNINGS=$((WARNINGS + 1))
            return 1
        fi
    fi
}

# Check Oh My Zsh configuration
check_oh_my_zsh() {
    echo ""
    log_info "Checking Oh My Zsh installation..."

    check_directory "Oh My Zsh" "$HOME/.oh-my-zsh" "optional"
    check_directory "Powerlevel10k theme" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "optional"
    check_directory "zsh-autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "optional"
    check_directory "zsh-syntax-highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "optional"

    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            local plugins=$(grep "^plugins=" "$HOME/.zshrc" | sed 's/plugins=(\(.*\))/\1/')
            log_info "Enabled plugins: $plugins"
        fi
    fi
}

# Check programming languages
check_languages() {
    echo ""
    log_info "Checking programming languages..."

    check_tool "Python 3.12" "python3.12" "--version" "optional"
    check_tool "Python 3" "python3" "--version" "optional"
    check_tool "Node.js" "node" "--version" "optional"
    check_tool "npm" "npm" "--version" "optional"
}

# Check Kubernetes tools
check_kubernetes_tools() {
    echo ""
    log_info "Checking Kubernetes tools..."

    check_tool "kubectl" "kubectl" "version --client --short" "optional"
    check_tool "kubectx" "kubectx" "--help" "optional"
    check_tool "kubens" "kubens" "--help" "optional"
    check_tool "k9s" "k9s" "version" "optional"
}

# Check AWS tools
check_aws_tools() {
    echo ""
    log_info "Checking AWS tools..."

    check_tool "Granted" "granted" "--version" "optional"

    # Check assume alias
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ -f "$HOME/.zshrc" ] && grep -q "alias assume=" "$HOME/.zshrc"; then
        log_success "assume alias is configured"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        log_warning "assume alias is NOT configured"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Check development tools
check_dev_tools() {
    echo ""
    log_info "Checking development tools..."

    check_tool "Claude Code" "claude" "--help" "optional"
    check_tool "envchain" "envchain" "--help" "optional"
}

# Check network tools
check_network_tools() {
    echo ""
    log_info "Checking network tools..."

    check_tool "lsof" "lsof" "-v" "optional"
    check_tool "nmap" "nmap" "--version" "optional"
}

# Check Ubuntu-specific tools
check_ubuntu_tools() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    echo ""
    log_info "Checking Ubuntu-specific tools..."

    # Check WSL utilities
    check_tool "wslu (wslview)" "wslview" "--help" "optional"

    # Check gnome-keyring
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if dpkg -l | grep -q gnome-keyring; then
        log_success "gnome-keyring is installed"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))

        # Check if daemon is running
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if [ -n "$GNOME_KEYRING_CONTROL" ]; then
            log_success "gnome-keyring daemon is running"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_warning "gnome-keyring daemon is NOT running"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        log_warning "gnome-keyring is NOT installed"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check git credential helper
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if command_exists git; then
        local helper=$(git config --global credential.helper 2>/dev/null || echo "")
        if [[ "$helper" == *"libsecret"* ]]; then
            log_success "git credential helper is configured (libsecret)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_warning "git credential helper is NOT configured"
            log_info "  Current: ${helper:-none}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# Check macOS-specific tools
check_macos_tools() {
    if [[ "$OS" != "macos" ]]; then
        return 0
    fi

    echo ""
    log_info "Checking macOS-specific tools..."

    check_tool "Homebrew" "brew" "--version" "optional"

    if command_exists brew; then
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if brew doctor > /dev/null 2>&1; then
            log_success "Homebrew is healthy"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            log_warning "Homebrew has warnings (run 'brew doctor' for details)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# Main doctor function
main() {
    show_banner

    echo "Running comprehensive health check..."
    echo ""

    log_info "Detected OS: $OS"
    log_info "Architecture: $(uname -m)"
    echo ""

    # Run all checks
    check_oh_my_zsh
    check_languages
    check_kubernetes_tools
    check_aws_tools
    check_dev_tools
    check_network_tools
    check_ubuntu_tools
    check_macos_tools

    # Summary
    echo ""
    echo "======================================"
    echo "  Health Check Summary"
    echo "======================================"
    echo ""
    echo "Total checks: $TOTAL_CHECKS"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo ""

    # Calculate success rate
    local success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

    if [ $FAILED_CHECKS -gt 0 ]; then
        log_error "Some critical checks failed!"
        echo ""
        log_info "To fix issues, run: ./setup.sh"
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        log_warning "All critical checks passed, but some optional tools are missing"
        log_info "Success rate: ${success_rate}%"
        echo ""
        log_info "To install missing tools, run: ./setup.sh"
        exit 0
    else
        log_success "All checks passed! (${success_rate}%)"
        echo ""
        log_info "Your machine is fully configured!"
        exit 0
    fi
}

# Run main function
main
