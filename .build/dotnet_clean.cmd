rem ============================================================
rem Clean (.NET)
rem ============================================================
set "TEST_SOLUTION=tests\dotnet\Tests.sln"

if /i "%FLAVOR%"=="debug"   set "DOTNET_CONFIG=Debug"
if /i "%FLAVOR%"=="release" set "DOTNET_CONFIG=Release"

dotnet clean "%TEST_SOLUTION%" -c "%DOTNET_CONFIG%" --nologo -p:Platform="%ARCH%" || exit /b %errorlevel%

exit /b 0
