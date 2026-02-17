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

die() {
    echo "error: $*" 1>&2
    exit 2
}

# ------------------------------------------------------------
# Argument parsing (simple, deterministic)
# ------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        build|clean|rebuild) COMMAND="$1" ;;
        debug|release) CONFIG="$1" ;;
        x64|x86|arm|aarch64) ARCH="$1" ;;
        gcc|clang) TOOLCHAIN="$1" ;;
        --cmake:*) EXTRA_CMAKE_ARGS+=("${1#--cmake:}") ;;
        --cmake-build:*) EXTRA_CMAKE_BUILD_ARGS+=("${1#--cmake-build:}") ;;
        *) die "unrecognized argument '$1'" ;;
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
# Host arch detection (for cross compile decisions)
# ------------------------------------------------------------
detect_host_arch() {
    local u
    u="$(uname -m)"
    case "$u" in
        x86_64) echo "x64" ;;
        i386|i486|i586|i686) echo "x86" ;;
        aarch64|arm64) echo "aarch64" ;;
        armv7l|armv7*|armhf) echo "arm" ;;
        *) echo "$u" ;;
    esac
}

HOST_ARCH="$(detect_host_arch)"

# ------------------------------------------------------------
# Toolchain file selection (static, repo-owned)
# ------------------------------------------------------------
TOOLCHAIN_FILE_REL=".cmake/${ARCH}.cmake"
TOOLCHAIN_FILE_ABS="${REPO_ROOT}/${TOOLCHAIN_FILE_REL}"
[[ -f "$TOOLCHAIN_FILE_ABS" ]] || die "missing toolchain file: ${TOOLCHAIN_FILE_REL}"

# ------------------------------------------------------------
# Cross / native determination
# ------------------------------------------------------------
CROSS=0
if [[ "$ARCH" != "$HOST_ARCH" ]]; then
    CROSS=1
fi

# ------------------------------------------------------------
# Compiler selection
# ------------------------------------------------------------
if [[ "$TOOLCHAIN" == "clang" ]]; then
    if [[ "$CROSS" -eq 1 ]]; then
        die "clang cross compile not supported in v1 (host=${HOST_ARCH}, arch=${ARCH}). Use gcc or extend toolchain support."
    fi
    export CC=clang
    export CXX=clang++
else
    if [[ "$CROSS" -eq 1 ]]; then
        case "$ARCH" in
            x86)
                export CC=i686-linux-gnu-gcc
                export CXX=i686-linux-gnu-g++
                ;;
            arm)
                export CC=arm-linux-gnueabihf-gcc
                export CXX=arm-linux-gnueabihf-g++
                ;;
            aarch64)
                export CC=aarch64-linux-gnu-gcc
                export CXX=aarch64-linux-gnu-g++
                ;;
            x64)
                die "cross compile to x64 not supported in v1 (host=${HOST_ARCH})"
                ;;
            *)
                die "unsupported arch '$ARCH' (expected x64|x86|arm|aarch64)"
                ;;
        esac
    else
        export CC=gcc
        export CXX=g++
    fi
fi

# ------------------------------------------------------------
# Build / Install directories
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
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE_ABS" \
    -DCMAKE_BUILD_TYPE="$CMAKE_CONFIG" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR_ABS" \
    "${EXTRA_CMAKE_ARGS[@]}"

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------
cmake --build "$BUILD_DIR_ABS" "${EXTRA_CMAKE_BUILD_ARGS[@]}"

# ------------------------------------------------------------
# Install
# ------------------------------------------------------------
cmake --install "$BUILD_DIR_ABS"