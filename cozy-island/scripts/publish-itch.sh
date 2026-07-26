#!/usr/bin/env bash
# Build and publish Cozy Island to itch.io using Butler.
# Usage: ./scripts/publish-itch.sh [--skip-build]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROJECT="${ITCH_PROJECT:-0xleathery/cozy-island}"
CHANNEL="${ITCH_CHANNEL:-web}"
ZIP_PATH="build/cozy-island-web.zip"
SKIP_BUILD=false

for arg in "$@"; do
	case "$arg" in
		--skip-build) SKIP_BUILD=true ;;
		-h|--help)
			echo "Usage: $0 [--skip-build]"
			echo "  ITCH_PROJECT  default: 0xleathery/cozy-island"
			echo "  ITCH_CHANNEL  default: web"
			echo "  BUTLER_API_KEY  required in CI; use 'butler login' locally"
			exit 0
			;;
	esac
done

require_butler() {
	if command -v butler >/dev/null 2>&1; then
		BUTLER=butler
		return
	fi
	if [[ -x "$ROOT/tools/butler/butler" ]]; then
		BUTLER="$ROOT/tools/butler/butler"
		return
	fi
	echo "Butler not found. Run: ./scripts/install-butler.sh"
	exit 1
}

build_web() {
	local godot=""
	for candidate in godot Godot godot4 Godot4; do
		if command -v "$candidate" >/dev/null 2>&1; then
			godot="$candidate"
			break
		fi
	done
	if [[ -z "$godot" ]]; then
		echo "Godot not found in PATH. Install Godot 4.3 or export manually first."
		exit 1
	fi

	echo "==> Exporting web build with $godot"
	mkdir -p build/web
	"$godot" --headless --path "$ROOT" --export-release "Web" "$ROOT/build/web/index.html"

	echo "==> Packaging zip"
	(
		cd build/web
		zip -r ../cozy-island-web.zip . -q
	)
}

publish() {
	require_butler
	if [[ ! -f "$ZIP_PATH" ]]; then
		echo "Missing $ZIP_PATH — run without --skip-build first."
		exit 1
	fi

	echo "==> Pushing to itch.io: ${PROJECT}:${CHANNEL}"
	"$BUTLER" push "$ZIP_PATH" "${PROJECT}:${CHANNEL}"
	echo "==> Done! https://${PROJECT%%/*}.itch.io/${PROJECT##*/}"
	"$BUTLER" status "${PROJECT}:${CHANNEL}" || true
}

if [[ "$SKIP_BUILD" == false ]]; then
	build_web
fi
publish
