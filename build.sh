#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# build.sh
#
# Usage:
#   ./build.sh [build|clean|rebuild] [debug|release] [x64|x86|arm|aarch64] [gcc|clang] [--cmake:"args..."] [--cmake-build:"args..."]
#
# Defaults:
#   build debug x64 gcc
# ============================================================

# ------------------------------------------------------------
# Defaults
# ------------------------------------------------------------
COMMAND=build
CONFIG=debug
ARCH=x64
TOOLCHAIN=gcc
EXTRA_CMAKE_ARGS=()
EXTRA_CMAKE_BUILD_ARGS=()

# ------------------------------------------------------------
# Argument parsing. Need to build it smarter someday.
# ------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        build|clean|rebuild) COMMAND="$1" ;;
        debug|release) CONFIG="$1" ;;
        x64|x86|arm|aarch64) ARCH="$1" ;;
        gcc|clang) TOOLCHAIN="$1" ;;
        --cmake:*) EXTRA_CMAKE_ARGS+=("${1#--cmake:}") ;;
        --cmake-build:*) EXTRA_CMAKE_BUILD_ARGS+=("${1#--cmake-build:}") ;;
        *) die() { echo "ERROR: $*" >&2; exit 1; } ;;
    esac
    shift
done

# Normalize config
if [[ "$CONFIG" == "debug" ]]; then
    CMAKE_CONFIG=Debug
else
    CMAKE_CONFIG=Release
fi

# ------------------------------------------------------------
# Resolve repo root (anchor paths; do not cd)
# ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# ------------------------------------------------------------
# Environment loading (simple KEY=VALUE, no shell evaluation)
# ------------------------------------------------------------
load_env() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    while IFS='=' read -r key value; do
        [[ -z "$key" ]] && continue
        [[ "$key" == \#* ]] && continue
        # Trim whitespace (minimal)
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        export "$key=$value"
    done < "$file"
}

# Layered env files (explicit, no magic)
load_env "$REPO_ROOT/.env/global.env"
load_env "$REPO_ROOT/.env/linux.env"
load_env "$REPO_ROOT/.env/${TOOLCHAIN}.env"
load_env "$REPO_ROOT/.env/local.env"

# ------------------------------------------------------------
# Toolchain resolution
# ------------------------------------------------------------
if [[ "$TOOLCHAIN" == "clang" ]]; then
    export CC=clang
    export CXX=clang++
else
    export CC=gcc
    export CXX=g++
fi

# ------------------------------------------------------------
# Build / Install directories (relative to repo root)
# ------------------------------------------------------------
BUILD_DIR="build/${ARCH}/${CMAKE_CONFIG}"
INSTALL_DIR="out/${ARCH}/${CMAKE_CONFIG}"

BUILD_DIR_ABS="${REPO_ROOT}/${BUILD_DIR}"
INSTALL_DIR_ABS="${REPO_ROOT}/${INSTALL_DIR}"

# ------------------------------------------------------------
# Commands
# ------------------------------------------------------------
if [[ "$COMMAND" == "clean" ]]; then
    rm -rf "$BUILD_DIR_ABS" "$INSTALL_DIR_ABS"
    exit 0
fi

if [[ "$COMMAND" == "rebuild" ]]; then
    rm -rf "$BUILD_DIR_ABS" "$INSTALL_DIR_ABS"
fi

# ------------------------------------------------------------
# Configure
# ------------------------------------------------------------
cmake \
    -S "$REPO_ROOT" \
    -B "$BUILD_DIR_ABS" \
    -DCMAKE_BUILD_TYPE="$CMAKE_CONFIG" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR_ABS" \
    "${EXTRA_CMAKE_ARGS[@]}"

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------
cmake --build "$BUILD_DIR_ABS" "${EXTRA_CMAKE_BUILD_ARGS[@]}"

# ------------------------------------------------------------
# Install (single-config generators on Linux/WSL)
# ------------------------------------------------------------
cmake --install "$BUILD_DIR_ABS"
