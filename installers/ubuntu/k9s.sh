#!/usr/bin/env bash

# Install k9s on Ubuntu
# Downloads from GitHub releases (not available via apt)

# Get script directory
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALLER_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

install_k9s() {
    # Check if k9s is already installed
    if command -v k9s &> /dev/null; then
        log_info "k9s is already installed (version: $(k9s version --short 2>/dev/null || echo 'installed'))"
        return 0
    fi

    log_info "Installing k9s..."

    # Install from GitHub releases (latest version)
    curl -OL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
    sudo tar -zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin/ k9s
    rm k9s_Linux_amd64.tar.gz

    log_info "k9s installed successfully"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_k9s
fi
