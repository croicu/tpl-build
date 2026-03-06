#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# build.sh
#
# Usage:
#   ./deploy.sh user@computer [debug|release] [x64|x86|arm|aarch64
#
# Defaults:
#   debug x64
# ============================================================

CONFIG=debug
ARCH=x64

WHERE="${1:-}"
shift || true

if [[ -z "$WHERE" ]]; then
    die() { echo "WHERE argument is required." >&2; exit 1; }
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        debug|release|ship) CONFIG="$1" ;;
        x64|x86|arm|aarch64) ARCH="$1" ;;
        *) die() { echo "ERROR: $*" >&2; exit 1; } ;;
    esac
    shift
done

case "$CONFIG" in
    release|ship) FLAVOR=Release ;;
    *)            FLAVOR=Debug ;;
esac

INSTALL_DIR="out/${ARCH}/${FLAVOR}"
[[ -d "$INSTALL_DIR" ]] || die() { echo "Install directory not found: $INSTALL_DIR" >&2; exit 1; }


rsync --info=progress2 -e "ssh" "$INSTALL_DIR/manifest.json" $WHERE:"/var/www/tpl-build/" || exit 1
rsync -r --info=progress2 -e "ssh" "$INSTALL_DIR/templates/" $WHERE:"/var/www/tpl-build/" || exit 1
