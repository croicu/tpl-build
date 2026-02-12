#!/usr/bin/env sh
set -eu

: "${ARCH:?ARCH not set}"
: "${CONFIG:?CONFIG not set}"
WS_ROOT="${WS_ROOT:-$(pwd)}"
BUILD_DIR="${WS_ROOT}/build"

cmake \
  -S "${WS_ROOT}" \
  -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE="${CONFIG}"

cmake \
  --build "${BUILD_DIR}"
