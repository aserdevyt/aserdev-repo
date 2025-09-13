#!/bin/bash
set -e

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
    cp "$PKGFILE" "$REPO_DIR/"

    popd > /dev/null
done

# Clean old versions in repo
cd "$REPO_DIR"
for pkg in *.pkg.tar.zst; do
    base=$(echo "$pkg" | sed -E 's/-[0-9]+-[^-]+\.pkg\.tar\.zst$//')
    latest=$(ls -t "$base"-*.pkg.tar.zst | head -n1)

    for old in $(ls "$base"-*.pkg.tar.zst | grep -v "$latest"); do
        echo "==> Removing old $old"
        rm -f "$old"
    done
done

# Update repo database
echo "==> Updating repo database"
repo-add -n -R "$REPO_NAME.db.tar.gz" *.pkg.tar.zst

# Create pacman-friendly symlinks
ln -sf "$REPO_NAME.db.tar.gz" "$REPO_NAME.db"
ln -sf "$REPO_NAME.files.tar.gz" "$REPO_NAME.files"


