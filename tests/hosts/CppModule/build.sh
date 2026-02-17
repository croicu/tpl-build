#!/usr/bin/env sh
set -eu

COMMAND=build
CONFIG=Debug
ARCH=x64
TOOLCHAIN=gcc
EXTRA_CMAKE_ARGS=()
EXTRA_CMAKE_BUILD_ARGS=()

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WS_ROOT="$SCRIPT_DIR"

# Normalize config
if [[ "$CONFIG" == "debug" ]]; then
    CMAKE_CONFIG=Debug
else
    CMAKE_CONFIG=Release
fi

if [[ "$TOOLCHAIN" == "clang" ]]; then
    export CC=clang
    export CXX=clang++
else
    export CC=gcc
    export CXX=g++
fi

WS_ROOT="${WS_ROOT:-$(pwd)}"
BUILD_DIR="${WS_ROOT}/build"
INSTALL_DIR="${WS_ROOT}/out/${ARCH}/${CMAKE_CONFIG}"

cmake \
  -S "${WS_ROOT}" \
  -B "${BUILD_DIR}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  -DCMAKE_BUILD_TYPE="${CMAKE_CONFIG}"

cmake \
  --build "${BUILD_DIR}"

cmake \
  --install "${BUILD_DIR}"
