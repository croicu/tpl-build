@echo off
rem ============================================================
rem build.bat
rem Usage:
rem   build.bat [build|rebuild|test|register|clean|zap] [debug|release] [x64|x86|arm] [msvc|clang] [--cmake:"args..."] [--cmake-build:"args..."]
rem Defaults:
rem   build Debug x64 msvc
rem ============================================================
setlocal EnableExtensions EnableDelayedExpansion

set "COMMAND=build"
set "FLAVOR=debug"
set "ARCH=x64"
set "TOOLCHAIN=msvc"
set "EXTRA_CMAKE_ARGS="
set "EXTRA_CMAKE_BUILD_ARGS="
set "EXPERIMENTAL=0"

call .build\args_parse.cmd %* || goto :error
call .build\env_load.cmd || goto :error

set "BUILD_DIR=build\%ARCH_DIR%\%FLAVOR%"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
set "INSTALL_DIR=out\%ARCH_DIR%\%FLAVOR%"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
set "RESULTS_DIR=logs\tests\%ARCH%\%DOTNET_CONFIG%"
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

rem Zap
if /i "%COMMAND%"=="zap" (
  call .build\zap.cmd || goto :error
  goto :eof
)

call .build\vs_detect.cmd || goto :error

rem Register
if /i "%COMMAND%"=="register" (
  call .build\register_templates.cmd || goto :error
  goto :eof
)

call .build\toolchain_msvc.cmd || goto :error

rem Clean / Rebuild
echo clean rebuild test | findstr /i "\<%COMMAND%\>" >nul && (
  call .build\cmake_clean.cmd || goto :error
  call .build\dotnet_clean.cmd || goto :error
)

if /i "%COMMAND%"=="clean" (
  goto :eof
)

rem Build / Install / Test
echo build rebuild | findstr /i "\<%COMMAND%\>" >nul && (
  call .build\cmake_build.cmd || goto :error
  call .build\dotnet_build.cmd || goto :error

  goto :eof
)

if /i "%COMMAND%"=="test" (
  call .build\cmake_build.cmd || goto :error
  call .build\dotnet_build.cmd || goto :error
  call .build\dotnet_test.cmd || goto :error

  goto :eof
)

:error
echo ERROR: build failed.
exit /b 1
