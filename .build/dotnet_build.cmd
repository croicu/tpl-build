rem ============================================================
rem dotnet_build.cmd
rem Inputs:
rem   FLAVOR = debug|release  (from build.bat)
rem ============================================================

set "TEST_SOLUTION=tests\dotnet\Tests.sln"

if /i "%FLAVOR%"=="debug"   set "DOTNET_CONFIG=Debug"
if /i "%FLAVOR%"=="release" set "DOTNET_CONFIG=Release"

rem Build.
dotnet build "%TEST_SOLUTION%" -c "%DOTNET_CONFIG%" --nologo -p:Platform="%ARCH%"

exit /b 0
