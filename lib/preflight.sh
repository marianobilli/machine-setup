#!/usr/bin/env bash

# Pre-flight checks for machine setup
# This file should be sourced after common.sh

# Source common utilities if not already loaded
if [ -z "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    # shellcheck source=lib/common.sh
    source "${SCRIPT_DIR}/lib/common.sh"
fi

# Check disk space (requires at least 2GB free)
check_disk_space() {
    local required_mb=2048
    local available_mb

    log_debug "Checking available disk space..."

    if command_exists df; then
        # Get available space in MB
        available_mb=$(df -m "$HOME" | tail -1 | awk '{print $4}')

        if [ "$available_mb" -lt "$required_mb" ]; then
            log_error "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
            return 1
        else
            log_success "Disk space check passed (${available_mb}MB available)"
            return 0
        fi
    else
        log_warning "Cannot check disk space (df command not found)"
        return 0
    fi
}

# Check internet connectivity
check_internet() {
    log_debug "Checking internet connectivity..."

    local test_urls=(
        "https://github.com"
        "https://raw.githubusercontent.com"
        "https://google.com"
    )

    for url in "${test_urls[@]}"; do
        if curl -fsSL --max-time 5 "$url" > /dev/null 2>&1; then
            log_success "Internet connectivity check passed"
            return 0
        fi
    done

    log_error "No internet connectivity detected"
    log_error "Please check your network connection and try again"
    return 1
}

# Check if sudo is available (Linux only)
check_sudo() {
    if [[ "$OS" != "ubuntu" ]]; then
        return 0
    fi

    log_debug "Checking sudo access..."

    if ! command_exists sudo; then
        log_error "sudo command not found. Please install sudo first."
        return 1
    fi

    # Test sudo access without actually executing anything
    if sudo -n true 2>/dev/null; then
        log_success "Sudo access verified"
        return 0
    else
        log_warning "Sudo access requires password. You may be prompted during installation."
        # Try to get sudo access
        if sudo -v; then
            log_success "Sudo access granted"
            return 0
        else
            log_error "Cannot obtain sudo access"
            return 1
        fi
    fi
}

# Check if zsh is installed
check_zsh() {
    log_debug "Checking for zsh..."

    if command_exists zsh; then
        local zsh_version=$(zsh --version | awk '{print $2}')
        log_success "zsh is installed (version: $zsh_version)"
        return 0
    else
        log_error "zsh is not installed. Please install zsh first."
        log_info "On Ubuntu: sudo apt install zsh"
        log_info "On macOS: brew install zsh (or use built-in zsh)"
        return 1
    fi
}

# Check system architecture
check_architecture() {
    log_debug "Checking system architecture..."

    local arch=$(uname -m)

    case "$arch" in
        x86_64|amd64)
            log_success "Architecture: x86_64 (supported)"
            export SYSTEM_ARCH="x86_64"
            return 0
            ;;
        arm64|aarch64)
            log_success "Architecture: ARM64 (supported)"
            export SYSTEM_ARCH="arm64"
            return 0
            ;;
        *)
            log_warning "Architecture: $arch (may not be fully supported)"
            export SYSTEM_ARCH="$arch"
            return 0
            ;;
    esac
}

# Check for conflicting installations
check_conflicts() {
    log_debug "Checking for potential conflicts..."

    local conflicts_found=false

    # Check if Homebrew is in an unexpected state (macOS)
    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            if ! brew doctor > /dev/null 2>&1; then
                log_warning "Homebrew may have issues. Run 'brew doctor' to diagnose."
                conflicts_found=true
            fi
        fi
    fi

    # Check if Oh My Zsh is installed but corrupted
    if [ -d "$HOME/.oh-my-zsh" ]; then
        if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
            log_warning "Oh My Zsh directory exists but appears corrupted"
            conflicts_found=true
        fi
    fi

    if [ "$conflicts_found" = false ]; then
        log_success "No conflicts detected"
    fi

    return 0  # Don't fail on conflicts, just warn
}

# Check required tools for installation
check_required_tools() {
    log_debug "Checking required installation tools..."

    local required_tools=("curl" "git")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install these tools before running setup"
        return 1
    else
        log_success "All required tools are installed"
        return 0
    fi
}

# Run all pre-flight checks
run_preflight_checks() {
    log_info "Running pre-flight checks..."
    echo ""

    local checks_passed=true

    # Critical checks (must pass)
    if ! check_required_tools; then
        checks_passed=false
    fi

    if ! check_architecture; then
        checks_passed=false
    fi

    if ! check_zsh; then
        checks_passed=false
    fi

    if ! check_sudo; then
        checks_passed=false
    fi

    if ! check_disk_space; then
        checks_passed=false
    fi

    if ! check_internet; then
        checks_passed=false
    fi

    # Non-critical checks (can fail)
    check_conflicts

    echo ""

    if [ "$checks_passed" = true ]; then
        log_success "All pre-flight checks passed!"
        echo ""
        return 0
    else
        log_error "Some pre-flight checks failed. Please address the issues above."
        echo ""
        return 1
    fi
}
