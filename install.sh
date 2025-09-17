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

# ----------------------------
# Helper Functions
# ----------------------------
repo_exists() {
    grep -q "^\[$1\]" "$PACMAN_CONF"
}

repo_works() {
    sudo pacman -Sy --noconfirm &>/dev/null || return 1
    pacman -Sl "$1" &>/dev/null
}

remove_repo() {
    echo "==> Removing [$1] from $PACMAN_CONF..."
    sudo sed -i "/^\[$1\]/,/^$/d" "$PACMAN_CONF"
    echo "Repo [$1] removed ✅"
}

# ----------------------------
# Handle Arguments
# ----------------------------
if [[ "${1:-}" == "-R" ]]; then
    if repo_exists "$REPO_NAME"; then
        remove_repo "$REPO_NAME"
        sudo pacman -Sy --noconfirm
    else
        echo "[$REPO_NAME] not found in pacman.conf, nothing to remove."
    fi
    exit 0
fi

# ----------------------------
# Chaotic AUR Setup
# ----------------------------
echo "==> Checking Chaotic AUR..."

chaotic_ok=true
if ! repo_exists "chaotic-aur" || ! repo_works "chaotic-aur"; then
    echo "Chaotic AUR not working, trying to set it up..."
    {
        # Import signing key if missing
        if ! pacman-key --list-keys | grep -q "3056513887B78AEB"; then
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
        fi

        # Install keyring + mirrorlist if missing
        if ! pacman -Qi chaotic-keyring &>/dev/null; then
            sudo pacman -U \
              'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
              'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' \
              --noconfirm
        fi

        # Add Chaotic AUR repo
        if ! repo_exists "chaotic-aur"; then
            echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' \
              | sudo tee -a "$PACMAN_CONF"
        fi

        sudo pacman -Sy --noconfirm
        repo_works "chaotic-aur" || chaotic_ok=false
    } || chaotic_ok=false
fi

if [ "$chaotic_ok" = true ]; then
    echo "Chaotic AUR ready ✅"
else
    echo "⚠️ Chaotic AUR setup failed or mirrors are down, skipping..."
fi

# ----------------------------
# AserDev Repo Setup
# ----------------------------
echo "==> Checking $REPO_NAME repo..."

if curl -fsI "$REPO_URL" >/dev/null 2>&1; then
    if ! repo_exists "$REPO_NAME" || ! repo_works "$REPO_NAME"; then
        echo "Setting up $REPO_NAME repo..."
        echo -e "\n[$REPO_NAME]\nSigLevel = Optional TrustAll\nServer = $REPO_URL" \
          | sudo tee -a "$PACMAN_CONF"
        sudo pacman -Sy --noconfirm
    else
        echo "$REPO_NAME repo already present and working ✅"
    fi
else
    echo "❌ GitHub repo $REPO_URL is not reachable!"
    if repo_exists "$REPO_NAME"; then
        echo "Removing broken $REPO_NAME entry..."
        remove_repo "$REPO_NAME"
        sudo pacman -Sy --noconfirm
    fi
fi

# ----------------------------
# Finished
# ----------------------------
echo "==> All checks done 🎉"
echo "Example: sudo pacman -S brokefetch"
echo "Use './script.sh -R' to remove [$REPO_NAME]"
