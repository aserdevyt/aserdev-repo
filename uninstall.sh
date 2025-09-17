#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="aserdev"
PACMAN_CONF="/etc/pacman.conf"

remove_repo() {
    echo "==> Removing [$1] from $PACMAN_CONF..."
    sudo sed -i "/^\[$1\]/,/^$/d" "$PACMAN_CONF"
    echo "Repo [$1] removed ✅"
}

echo "==> Uninstalling $REPO_NAME repo..."

if grep -q "^\[$REPO_NAME\]" "$PACMAN_CONF"; then
    remove_repo "$REPO_NAME"
    sudo pacman -Sy --noconfirm
else
    echo "[$REPO_NAME] not found in $PACMAN_CONF, nothing to remove."
fi

echo "==> Done 🎉"
