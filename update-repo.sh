#!/bin/bash
set -euo pipefail

# Base repo folder
BASE_DIR="$HOME/aserdev-repo"
PKG_DIR="$BASE_DIR/PKGBUILDs"
REPO_DIR="$BASE_DIR/x86_64"
REPO_NAME="aserdev"

mkdir -p "$REPO_DIR"

# Build all PKGBUILDs inside PKGBUILDs/
find "$PKG_DIR" -name PKGBUILD | while read -r PKG; do
    PKGDIR=$(dirname "$PKG")
    pushd "$PKGDIR" > /dev/null

    echo "==> Building package in $PKGDIR"
    makepkg -sf --noconfirm

    # Find newest package built
    PKGFILE=$(ls -t *.pkg.tar.zst | head -n1)

    echo "==> Copying $PKGFILE to $REPO_DIR"
    cp -f "$PKGFILE" "$REPO_DIR/"

    popd > /dev/null
done

# Go to repo dir
cd "$REPO_DIR"

# Remove old db/files archives and symlinks
rm -f "$REPO_NAME".db* "$REPO_NAME".files*

# Clean old package versions (keep only latest per base name)
for pkg in *.pkg.tar.zst; do
    base=$(echo "$pkg" | sed -E 's/-[0-9]+-[^-]+\.pkg\.tar\.zst$//')
    latest=$(ls -t "$base"-*.pkg.tar.zst | head -n1)

    for old in $(ls "$base"-*.pkg.tar.zst | grep -v "$latest"); do
        echo "==> Removing old $old"
        rm -f "$old"
    done
done

# Rebuild repo database (compressed)
echo "==> Updating repo database"
repo-add -n -R "$REPO_NAME.db.tar.zst" ./*.pkg.tar.zst

# Recreate pacman-friendly symlinks
ln -sf "$REPO_NAME.db.tar.zst" "$REPO_NAME.db"
ln -sf "$REPO_NAME.files.tar.zst" "$REPO_NAME.files"

