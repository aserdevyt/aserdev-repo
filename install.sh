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
remove_repo() {
    echo "==> Removing [$1] from $PACMAN_CONF..."
    sudo sed -i "/^\[$1\]/,/^$/d" "$PACMAN_CONF"
    echo "Repo [$1] removed ✅"
}

# ----------------------------
# Handle Arguments
# ----------------------------
if [[ "${1:-}" == "-R" ]]; then
    remove_repo "$REPO_NAME"
    sudo pacman -Sy --noconfirm
    exit 0
fi

# ----------------------------
# Chaotic AUR Setup
# ----------------------------
echo "==> Setting up Chaotic AUR..."

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
    echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' \
      | sudo tee -a "$PACMAN_CONF"

    sudo pacman -Sy --noconfirm
} || echo "⚠️ Chaotic AUR setup failed, skipping..."

echo "Chaotic AUR setup done ✅"

# ----------------------------
# AserDev Repo Setup
# ----------------------------
echo "==> Adding $REPO_NAME repo..."

echo -e "\n[$REPO_NAME]\nSigLevel = Optional TrustAll\nServer = $REPO_URL" \
  | sudo tee -a "$PACMAN_CONF"

sudo pacman -Sy --noconfirm

# ----------------------------
# Finished
# ----------------------------
echo "==> All done 🎉"
echo "Example: sudo pacman -S brokefetch"
echo "Use './script.sh -R' to remove [$REPO_NAME]"
