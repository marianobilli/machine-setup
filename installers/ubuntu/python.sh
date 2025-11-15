#!/usr/bin/env bash

# Install Python 3.12 on Ubuntu
# This script should be sourced or called from the main setup script

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_python() {
    # Check if Python 3.12 is already installed
    if command -v python3.12 &> /dev/null; then
        log_info "Python 3.12 is already installed"
        return 0
    fi

    log_info "Installing Python 3.12..."

    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.12 python3.12-venv python3.12-dev
    # Set python3.12 as alternative
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

    log_info "Python 3.12 installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_python
fi
