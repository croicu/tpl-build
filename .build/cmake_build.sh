# ============================================================
# dotnet_build.sh
# Inputs:
#   CMAKE_CONFIG = Debug|Release  (from build.sh)
#   ARCH = x64|x86|arm|aarch64  (from build.sh)
# ============================================================

cmake_build() {
    # ------------------------------------------------------------
    # Configure
    # ------------------------------------------------------------
    if ! cmake \
        -S "$REPO_ROOT" \
        -B "$BUILD_DIR_ABS" \
        -DCMAKE_BUILD_TYPE="$CMAKE_CONFIG" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR_ABS" \
        "${EXTRA_CMAKE_ARGS[@]}";
    then
        return 1
    fi


    # ------------------------------------------------------------
    # Build
    # ------------------------------------------------------------
    if ! cmake --build "$BUILD_DIR_ABS" "${EXTRA_CMAKE_BUILD_ARGS[@]}"; then
        return 1
    fi 

    # ------------------------------------------------------------
    # Install (single-config generators on Linux/WSL)
    # ------------------------------------------------------------
    if ! cmake --install "$BUILD_DIR_ABS"; then
        return 1
    fi

    return 0
}