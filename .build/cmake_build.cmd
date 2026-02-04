rem ============================================================
rem Configure
rem ============================================================
set "SENTINEL=%BUILD_DIR%\.configured.snt"
set "TOOLCHAIN_ARGS="
if not "%CMAKE_C_COMPILER%"==""  set "TOOLCHAIN_ARGS=%TOOLCHAIN_ARGS% -DCMAKE_C_COMPILER=%CMAKE_C_COMPILER%"
if not "%CMAKE_CXX_COMPILER%"=="" set "TOOLCHAIN_ARGS=%TOOLCHAIN_ARGS% -DCMAKE_CXX_COMPILER=%CMAKE_CXX_COMPILER%"

if not exist "%SENTINEL%" (
  "%CMAKE_EXE%" --no-warn-unused-cli -S . -B "%BUILD_DIR%" ^
      -G "%BUILD_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" ^
      -DCMAKE_BUILD_TYPE=%FLAVOR% ^
      %TOOLCHAIN_ARGS% ^
      %EXTRA_CMAKE_ARGS%

  copy /y nul "%SENTINEL%" >nul
)

rem ============================================================
rem Build
rem ============================================================
"%CMAKE_EXE%" --build "%BUILD_DIR%" %EXTRA_CMAKE_BUILD_ARGS%
if errorlevel 1 exit /b 1

rem ============================================================
rem Install
rem ============================================================
"%CMAKE_EXE%" --install "%BUILD_DIR%" --config %FLAVOR%
if errorlevel 1 exit /b 1

exit /b 0