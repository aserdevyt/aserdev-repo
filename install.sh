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

echo "==> installing choatic ar for depends"

# add signing key
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
# install the keyring,mirrorlist
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# add chaotic aur repo
echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist'   | sudo tee -a /etc/pacman.conf

# update
sudo pacman -Syu --noconfirm
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

