#!/usr/bin/env bash

# Generic Package Manager Installer
# Installs packages from config/packages.conf based on OS

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Function to install a package
install_package() {
    local package_name="$1"
    local macos_package="$2"
    local ubuntu_package="$3"
    local description="$4"

    log_info "Installing ${package_name}..."

    # Check if already installed
    if command -v "$package_name" &> /dev/null; then
        log_info "${package_name} is already installed"
        return 0
    fi

    if [[ "$OS" == "macos" ]]; then
        if [ -z "$macos_package" ]; then
            log_info "${package_name} is not available via package manager on macOS (may need custom installer)"
            return 0
        fi

        # Check if it's a tap formula (contains /)
        if [[ "$macos_package" == *"/"* ]]; then
            local tap="${macos_package%/*}"
            local formula="${macos_package##*/}"
            log_info "Adding tap: $tap"
            brew tap "$tap"
            brew install "$formula"
        else
            brew install "$macos_package"
        fi

    elif [[ "$OS" == "ubuntu" ]]; then
        if [ -z "$ubuntu_package" ]; then
            log_info "${package_name} is not available via package manager on Ubuntu (may need custom installer)"
            return 0
        fi

        sudo apt update
        # shellcheck disable=SC2086
        sudo apt install -y $ubuntu_package
    fi

    log_info "${package_name} installed successfully"
}

# Function to install all packages from config
install_all_packages() {
    local config_file="${SCRIPT_DIR}/config/packages.conf"

    if [ ! -f "$config_file" ]; then
        log_error "Package configuration file not found: $config_file"
        return 1
    fi

    log_info "Reading package configuration from $config_file"
    echo ""

    # Read and process config file
    while IFS='|' read -r package_name macos_package ubuntu_package description; do
        # Skip comments and empty lines
        [[ "$package_name" =~ ^#.*$ ]] && continue
        [[ -z "$package_name" ]] && continue

        install_package "$package_name" "$macos_package" "$ubuntu_package" "$description"
        echo ""
    done < "$config_file"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_all_packages
fi
