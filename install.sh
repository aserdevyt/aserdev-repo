#!/usr/bin/env bash
set -e

# ----------------------------
# Variables
# ----------------------------
REPO_NAME="aserdev"
GITHUB_USER="aserdevyt"
ARCH=$(uname -m)  # usually x86_64
PACMAN_CONF="/etc/pacman.conf"
REPO_URL="https://raw.githubusercontent.com/$GITHUB_USER/aserdev-repo/main/$ARCH"

# ----------------------------
# Add the repo to pacman.conf
# ----------------------------
echo "==> Adding $REPO_NAME repo to pacman.conf..."

if grep -q "^\[$REPO_NAME\]" "$PACMAN_CONF"; then
    echo "Repo $REPO_NAME already exists, skipping..."
else
    echo -e "\n[$REPO_NAME]\nSigLevel = Optional TrustAll\nServer = $REPO_URL" | sudo tee -a "$PACMAN_CONF"
    echo "Repo added!"
fi

# ----------------------------
# Update pacman database
# ----------------------------
echo "==> Updating pacman database..."
sudo pacman -Sy

# ----------------------------
# Done
# ----------------------------
echo "==> Done! You can now install packages from $REPO_NAME:"
echo "Example: sudo pacman -S brokefetch"

