rem ============================================================
rem Environment defaults
rem ============================================================
set "BUILD_GENERATOR=Ninja"
set "CMAKE_EXE=cmake"
set "CMAKE_MAKE_PROGRAM=ninja"
if /i "%TOOLCHAIN%"=="clang" (
  set "CMAKE_C_COMPILER=clang-cl"
  set "CMAKE_CXX_COMPILER=clang-cl"
) else (
  set "CMAKE_C_COMPILER=cl"
  set "CMAKE_CXX_COMPILER=cl"
)
set "VCVARSALL_BAT="
set "HAS_CXX=0"

rem ============================================================
rem Minimal .env loader (KEY=VALUE, empty lines ok)
rem ============================================================
call :load_env .env\global.env
call :load_env .env\windows.env
call :load_env .env\%TOOLCHAIN%.env
call :load_env .env\local.env

rem ============================================================
rem Normalize CONFIG
rem ============================================================
if /i "%FLAVOR%"=="debug"   set "FLAVOR=Debug"
if /i "%FLAVOR%"=="release" set "FLAVOR=Release"

rem ============================================================
rem Normalize ARCH (folder + vcvarsall arch)
rem ============================================================
set "ARCH_DIR=%ARCH%"
set "VCARCH=x64"

if /i "%ARCH%"=="x64" (
  set "ARCH_DIR=x64"
  set "VCARCH=x64"
) else if /i "%ARCH%"=="x86" (
  set "ARCH_DIR=x86"
  set "VCARCH=x86"
) else if /i "%ARCH%"=="arm" (
  set "ARCH_DIR=arm"
  set "VCARCH=arm64"
)

exit /b 0

rem ============================================================
rem Functions
rem ============================================================
:load_env
if not exist "%~1" goto :eof
for /f "usebackq tokens=1* delims==" %%A in ("%~1") do (
  if not "%%A"=="" set "%%A=%%B"
)
goto :eof

