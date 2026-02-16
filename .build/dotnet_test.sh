# ============================================================
# dotnet_test.sh
# Inputs:
#   CMAKE_CONFIG = Debug|Release    (from build.sh)
#   ARCH = x64|x86|arm|aarch64      (from build.sh)
# ============================================================

require_dotnet() {
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

dotnet_test() {
    export TEST_SOLUTION=tests/dotnet/Tests.sln
    export RUNSETTINGS=tests/dotnet/mstest.runsettings

    if ! dotnet test ${TEST_SOLUTION} -c "${CMAKE_CONFIG}" --nologo --settings "${RUNSETTINGS}" -p:Platform="${ARCH}" --logger "trx;LogFileName=${RESULTS_DIR}/tests.trx"; then
        return 1
    fi

    return 0
}
