#!/usr/bin/env bash
set -euo pipefail

# Paths
ROOT="$HOME/aserdev-repo"
PKG_DIR="$ROOT/PKGBUILDs"
REPO_DIR="$ROOT/x86_64"
REPO_DB="aserdev.db.tar.zst"

mkdir -p "$REPO_DIR"

# Build packages
for pkgbuild in "$PKG_DIR"/*/PKGBUILD; do
    pkgdir="$(dirname "$pkgbuild")"
    echo ">>> Building package in $pkgdir"

    # clean build, overwrite if already exists
    (cd "$pkgdir" && makepkg -sf --noconfirm --clean --cleanbuild --noprogressbar)

    # move built package(s)
    for pkgfile in "$pkgdir"/*.pkg.tar.zst; do
        echo ">>> Moving $(basename "$pkgfile")"
        mv -f "$pkgfile" "$REPO_DIR/"
    done
done

# Rebuild repo database safely
echo ">>> Rebuilding repo database"
cd "$REPO_DIR"

# Remove any stale db files
rm -f aserdev.db aserdev.db.tar.* aserdev.files aserdev.files.tar.*

# Correct way: repo-add updates db
repo-add "$REPO_DB" ./*.pkg.tar.zst

echo ">>> Done. Repository ready at $REPO_DIR"

