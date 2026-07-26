#!/usr/bin/env bash
# Install Butler CLI into cozy-island/tools/butler/
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/tools/butler"
mkdir -p "$DEST"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
	x86_64|amd64) ARCH="amd64" ;;
	aarch64|arm64) ARCH="arm64" ;;
	*)
		echo "Unsupported architecture: $ARCH"
		exit 1
		;;
esac

URL="https://broth.itch.zone/butler/${OS}-${ARCH}/LATEST/archive/default"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Downloading Butler from $URL"
curl -fsSL "$URL" -o "$TMP/butler.zip"
unzip -q "$TMP/butler.zip" -d "$TMP"

install -m 755 "$TMP/butler" "$DEST/butler"
echo "==> Installed: $DEST/butler"
"$DEST/butler" -V 2>/dev/null || "$DEST/butler" --version 2>/dev/null || true
echo ""
echo "Next steps:"
echo "  1. Add to PATH: export PATH=\"$DEST:\$PATH\""
echo "  2. Authenticate:  butler login"
echo "  3. Publish:       ./scripts/publish-itch.sh"
