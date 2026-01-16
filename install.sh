#!/usr/bin/env bash
#
# WordPress DeployKit - Quick Installer
# 
# This script downloads and executes the main WordPress deployment script
# from the GitHub repository.
#
# Usage:
#   wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/WordpressDeployment/main/install.sh | sudo bash
#   or
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/WordpressDeployment/main/install.sh | sudo bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Repository information (update these)
GITHUB_USER="${GITHUB_USER:-andrew-kemp}"
GITHUB_REPO="${GITHUB_REPO:-WordpressDeployment}"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
SCRIPT_NAME="wp-deploy.sh"

REPO_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${SCRIPT_NAME}"

# Helper functions
info() {
    echo -e "${GREEN}==>${NC} $*"
}

warn() {
    echo -e "${YELLOW}!!${NC} $*"
}

error() {
    echo -e "${RED}Error:${NC} $*" >&2
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)"
   exit 1
fi

# Check if we're on a supported OS
if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    warn "This script is designed for Ubuntu. You're running a different OS."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Display banner
cat <<'BANNER'
╔══════════════════════════════════════════════════╗
║                                                  ║
║        WordPress DeployKit - Installer          ║
║                                                  ║
║     Automated WordPress Deployment Tool         ║
║                                                  ║
╚══════════════════════════════════════════════════╝

BANNER

info "Downloading WordPress DeployKit..."
info "Source: ${REPO_URL}"

# Create temporary directory
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Download the script
cd "$TMPDIR"
if command -v wget >/dev/null 2>&1; then
    if ! wget -q "$REPO_URL" -O "$SCRIPT_NAME"; then
        error "Failed to download script using wget"
        exit 1
    fi
elif command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "$REPO_URL" -o "$SCRIPT_NAME"; then
        error "Failed to download script using curl"
        exit 1
    fi
else
    error "Neither wget nor curl is available. Please install one of them."
    exit 1
fi

# Verify the download
if [[ ! -f "$SCRIPT_NAME" ]] || [[ ! -s "$SCRIPT_NAME" ]]; then
    error "Downloaded script is missing or empty"
    exit 1
fi

# Make executable
chmod +x "$SCRIPT_NAME"

info "Download complete!"
info "Starting WordPress DeployKit..."
echo

# Execute the script
"./$SCRIPT_NAME"

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    echo
    info "WordPress DeployKit completed successfully!"
else
    error "WordPress DeployKit exited with code $EXIT_CODE"
    exit $EXIT_CODE
fi
