#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Variables
# ----------------------------
REPO_NAME="aserdev"
GITHUB_USER="aserdevyt"
ARCH=$(uname -m)  # usually x86_64
PACMAN_CONF="/etc/pacman.conf"
REPO_URL="https://raw.githubusercontent.com/$GITHUB_USER/aserdev-repo/main/$ARCH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper for colored output
print_status() { echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }

# ----------------------------
# Helper Functions
# ----------------------------
remove_repo() {
    local repo_name="$1"
    
    print_status "Removing [$repo_name] from $PACMAN_CONF..."

    if ! grep -q "^\[$repo_name\]" "$PACMAN_CONF"; then
        print_warning "Repository [$repo_name] not found in $PACMAN_CONF"
        return 0
    fi
    
    # Create a temporary file
    local tmpfile
    tmpfile=$(mktemp)
    
    # Remove the repository section more safely using awk
    awk -v repo="[$repo_name]" '
        $0 ~ "^"repo"$" {skip=1; next}
        /^\[.*\]/ {skip=0}
        !skip {print}
    ' "$PACMAN_CONF" > "$tmpfile"
    
    # Check if the temporary file is valid and not empty
    if [ -s "$tmpfile" ]; then
        sudo mv "$tmpfile" "$PACMAN_CONF"
        print_success "Repository [$repo_name] removed successfully"
    else
        rm "$tmpfile"
        print_error "Failed to remove repository [$repo_name]"
        return 1
    fi
}

# ----------------------------
# Handle Arguments
# ----------------------------
case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [-R] [-h]"
        echo "  -R    Remove the $REPO_NAME repository"
        echo "  -h    Show this help message"
        exit 0
        ;;
    -R)
        remove_repo "$REPO_NAME"
        if ! sudo pacman -Sy; then
            print_error "Failed to sync package databases"
            exit 1
        fi
        exit 0
        ;;
esac

# Request sudo privileges if needed
if [ "$EUID" -ne 0 ]; then
    print_status "Requesting sudo privileges..."
    if ! sudo -v; then
        print_error "Failed to obtain sudo privileges"
        exit 1
    fi
    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# ----------------------------
# Chaotic AUR Setup
# ----------------------------
if grep -q '^\[chaotic-aur\]' "$PACMAN_CONF"; then
    print_status "Chaotic AUR already configured, skipping..."
else
    print_status "Setting up Chaotic AUR..."

    {
        # Import signing key if missing
        if ! pacman-key --list-keys 3056513887B78AEB >/dev/null 2>&1; then
            for keyserver in "keyserver.ubuntu.com" "keys.openpgp.org"; do
                if sudo pacman-key --recv-key 3056513887B78AEB --keyserver "$keyserver" 2>/dev/null; then
                    sudo pacman-key --lsign-key 3056513887B78AEB
                    break
                fi
                print_warning "Failed to fetch key from $keyserver, trying next..."
            done
        fi

        # Install keyring + mirrorlist if missing
        if ! pacman -Qi chaotic-keyring &>/dev/null; then
            if ! sudo pacman -U --needed --noconfirm \
                'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
                'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then
                print_error "Failed to install Chaotic AUR keyring and mirrorlist"
                exit 1
            fi
        fi

        # Add Chaotic AUR repo
        echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' \
            | sudo tee -a "$PACMAN_CONF"

        sudo pacman -Sy
    } || {
        print_error "Chaotic AUR setup failed"
        exit 1
    }
fi

print_success "Chaotic AUR setup done"

# ----------------------------
# AserDev Repo Setup
# ----------------------------
if grep -q "^\[$REPO_NAME\]" "$PACMAN_CONF"; then
    print_status "$REPO_NAME repo already configured, skipping..."
else
    print_status "Adding $REPO_NAME repo..."

    # Verify repository URL is accessible
    if ! curl --head --fail --silent "$REPO_URL/aserdev.db" >/dev/null; then
        print_error "Repository URL is not accessible: $REPO_URL"
        exit 1
    fi

    echo -e "\n[$REPO_NAME]\nSigLevel = Optional TrustAll\nServer = $REPO_URL" \
        | sudo tee -a "$PACMAN_CONF"

    if ! sudo pacman -Sy; then
        print_error "Failed to sync package databases"
        exit 1
    fi
fi

# ----------------------------
# Finished
# ----------------------------
print_success "All done 🎉"
if grep -q "^\[$REPO_NAME\]" "$PACMAN_CONF"; then
    echo "Example: sudo pacman -S brokefetch"
    echo "Use '$0 -R' to remove $REPO_NAME repository"
fi

# ----------------------------
# Finished
# ----------------------------
print_success "All done 🎉"
echo "Example: sudo pacman -S brokefetch"
