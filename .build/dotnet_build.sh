# ============================================================
# dotnet_build.sh
# Inputs:
#   CMAKE_CONFIG = Debug|Release    (from build.sh)
#   ARCH = x64|x86|arm|aarch64      (from build.sh)
# ============================================================

dotnet_check() {
    if ! command -v dotnet >/dev/null 2>&1; then
        echo ""
        echo "ERROR: .NET SDK is required for tests but 'dotnet' was not found."
        echo "Install .NET 8 SDK (example on Ubuntu):"
        echo "  sudo apt install dotnet-sdk-8.0"
        echo ""
        return 1
    fi
    return 0
}

dotnet_build() {
    export TEST_SOLUTION=tests/dotnet/Tests.sln

    if ! dotnet build ${TEST_SOLUTION} -c "${CMAKE_CONFIG}" --nologo -p:Platform="${ARCH}"; then
        return 1
    fi

    return 0
}