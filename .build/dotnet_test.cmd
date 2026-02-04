rem ============================================================
rem test_mstest.cmd
rem Runs MSTest via dotnet test (serial by default).
rem ============================================================

set "TEST_SOLUTION=tests\dotnet\Tests.sln"
set "RUNSETTINGS=tests\dotnet\mstest.runsettings"

if /i "%FLAVOR%"=="debug"   set "DOTNET_CONFIG=Debug"
if /i "%FLAVOR%"=="release" set "DOTNET_CONFIG=Release"

dotnet test "%TEST_SOLUTION%" -c "%DOTNET_CONFIG%" --nologo --settings "%RUNSETTINGS%" -p:Platform="%ARCH%" --logger "trx;LogFileName=%RESULTS_DIR%\tests.trx
if errorlevel 1 exit /b 1

exit /b 0
