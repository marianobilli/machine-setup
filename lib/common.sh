#!/usr/bin/env bash

# Common utilities for machine-setup scripts
# This file should be sourced by other scripts

# Script version
SCRIPT_VERSION="2.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="${HOME}/.machine-setup/setup.log"
DRY_RUN=false
VERBOSE=false
DEBUG=false

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging functions with file output
log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_info() {
    local msg="$1"
    echo -e "${GREEN}[INFO]${NC} $msg"
    log_to_file "INFO: $msg"
}

log_error() {
    local msg="$1"
    echo -e "${RED}[ERROR]${NC} $msg" >&2
    log_to_file "ERROR: $msg"
}

log_warning() {
    local msg="$1"
    echo -e "${YELLOW}[WARNING]${NC} $msg"
    log_to_file "WARNING: $msg"
}

log_debug() {
    local msg="$1"
    if [ "$DEBUG" = true ] || [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[DEBUG]${NC} $msg"
        log_to_file "DEBUG: $msg"
    fi
}

log_success() {
    local msg="$1"
    echo -e "${GREEN}[✓]${NC} $msg"
    log_to_file "SUCCESS: $msg"
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
    read -r -p "Enter your choice (1 or 2): " choice

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

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Execute command with dry-run support
execute() {
    local cmd="$*"

    log_debug "Executing: $cmd"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would execute: $cmd"
        return 0
    fi

    if [ "$VERBOSE" = true ]; then
        eval "$cmd"
    else
        eval "$cmd" &> /dev/null
    fi

    return $?
}

# Load version configuration
load_versions() {
    local versions_file="${SCRIPT_DIR}/config/versions.conf"

    if [ -f "$versions_file" ]; then
        log_debug "Loading versions from $versions_file"
        # shellcheck source=config/versions.conf
        source "$versions_file"
    else
        log_warning "Version file not found: $versions_file"
    fi
}

# Load profile configuration
load_profile() {
    local profile_name="$1"
    local profile_file="${SCRIPT_DIR}/config/profiles/${profile_name}.conf"

    if [ -f "$profile_file" ]; then
        log_info "Loading profile: $profile_name"
        # shellcheck source=config/profiles/full.conf
        source "$profile_file"
        return 0
    else
        log_error "Profile not found: $profile_file"
        return 1
    fi
}

# Check if a tool should be installed based on profile
should_install() {
    local tool_var="$1"

    # If variable is not set, default to true (for backward compatibility)
    if [ -z "${!tool_var}" ]; then
        return 0
    fi

    # Check if tool is enabled in profile
    if [ "${!tool_var}" = true ]; then
        return 0
    else
        return 1
    fi
}

# Verify checksum (SHA256)
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"

    if [ -z "$expected_checksum" ]; then
        log_warning "No checksum provided for $file, skipping verification"
        return 0
    fi

    log_debug "Verifying checksum for $file"

    local actual_checksum
    if command_exists sha256sum; then
        actual_checksum=$(sha256sum "$file" | awk '{print $1}')
    elif command_exists shasum; then
        actual_checksum=$(shasum -a 256 "$file" | awk '{print $1}')
    else
        log_warning "No checksum tool available, skipping verification"
        return 0
    fi

    if [ "$actual_checksum" = "$expected_checksum" ]; then
        log_success "Checksum verified for $file"
        return 0
    else
        log_error "Checksum verification failed for $file"
        log_error "Expected: $expected_checksum"
        log_error "Got: $actual_checksum"
        return 1
    fi
}

# Download file with retry logic
download_file() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry=0

    log_debug "Downloading $url to $output"

    while [ $retry -lt $max_retries ]; do
        if curl -fsSL "$url" -o "$output"; then
            log_success "Downloaded $output"
            return 0
        else
            retry=$((retry + 1))
            log_warning "Download failed, retry $retry/$max_retries"
            sleep 2
        fi
    done

    log_error "Failed to download $url after $max_retries attempts"
    return 1
}

# Show banner
show_banner() {
    cat << "EOF"
======================================
    Machine Setup Script v2.0
======================================
EOF
    echo ""
}

# Show help message
show_help() {
    cat << EOF
Usage: ./setup.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show script version
    --dry-run               Show what would be done without making changes
    --verbose               Show detailed output
    --debug                 Show debug information
    --profile PROFILE       Use specific profile (minimal, full, k8s-dev)
    --list-profiles         List available profiles

PROFILES:
    minimal     - Essential tools only (oh-my-zsh, python, nodejs)
    full        - All available tools (default)
    k8s-dev     - Kubernetes development focus

EXAMPLES:
    ./setup.sh                          # Install all tools (full profile)
    ./setup.sh --profile minimal        # Install minimal toolset
    ./setup.sh --dry-run                # Preview what would be installed
    ./setup.sh --verbose --profile k8s-dev  # Verbose Kubernetes setup

For more information, see README.md
EOF
}

# List available profiles
list_profiles() {
    echo "Available profiles:"
    echo ""

    local profiles_dir="${SCRIPT_DIR}/config/profiles"

    if [ -d "$profiles_dir" ]; then
        for profile in "$profiles_dir"/*.conf; do
            if [ -f "$profile" ]; then
                local name=$(basename "$profile" .conf)
                local description=$(grep "^# " "$profile" | head -n 2 | tail -n 1 | sed 's/^# //')
                printf "  %-15s %s\n" "$name" "$description"
            fi
        done
    else
        log_error "Profiles directory not found: $profiles_dir"
    fi
}

# Get script directory
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do
        local dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    echo "$(cd -P "$(dirname "$source")" && pwd)"
}

# Export SCRIPT_DIR for use in other scripts
SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")}"
export SCRIPT_DIR
