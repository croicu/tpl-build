@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem build.bat
rem Usage:
rem   build.bat [build|clean|rebuild] [debug|release] [x64|x86|arm] [msvc|gcc|clang] [--cmake:"args..."] [--cmake-build:"args..."]
rem Defaults:
rem   build Debug x64 msvc
rem ============================================================

rem ============================================================
rem Argument parsing. Need to make it smarter someday.
rem ============================================================
set "COMMAND=build"
set "FLAVOR=debug"
set "ARCH=x64"
set "TOOLCHAIN=msvc"
set "EXTRA_CMAKE_ARGS="
set "EXTRA_CMAKE_BUILD_ARGS="

:parse
if "%~1"=="" goto :parsed

set "ARG=%~1"

if /i "%ARG%"=="build"   set "COMMAND=build"   & shift & goto :parse
if /i "%ARG%"=="rebuild" set "COMMAND=rebuild" & shift & goto :parse
if /i "%ARG%"=="clean"   set "COMMAND=clean"   & shift & goto :parse

if /i "%ARG%"=="debug"   set "FLAVOR=debug"   & shift & goto :parse
if /i "%ARG%"=="release" set "FLAVOR=release" & shift & goto :parse

if /i "%ARG%"=="x64" set "ARCH=x64" & shift & goto :parse
if /i "%ARG%"=="x86" set "ARCH=x86" & shift & goto :parse

if /i "%ARG%"=="msvc"  set "TOOLCHAIN=msvc"  & shift & goto :parse
if /i "%ARG%"=="clang" set "TOOLCHAIN=clang" & shift & goto :parse

if /i "%ARG:~0,8%"=="--cmake:" (
  set "EXTRA_CMAKE_ARGS=%ARG:~8%"
  shift
  goto :parse
)

if /i "%ARG:~0,14%"=="--cmake-build:" (
  set "EXTRA_CMAKE_BUILD_ARGS=%ARG:~14%"
  shift
  goto :parse
)

echo ERROR: Unknown argument: %ARG%
exit /b 1
:parsed

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

set "BUILD_DIR=build\%ARCH_DIR%\%FLAVOR%"
set "INSTALL_DIR=out\%ARCH_DIR%\%FLAVOR%"

rem ============================================================
rem Clean / Rebuild
rem ============================================================
echo clean rebuild | findstr /i "\<%COMMAND%\>" >nul && (
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    if exist "%INSTALL_DIR%"  rmdir /s /q "%INSTALL_DIR%"
)
if /i "%COMMAND%"=="clean" (
  goto :eof
)

rem ============================================================
rem Toolchain activation (MSVC-like: MSVC + clang-cl)
rem ============================================================
if defined VSINSTALLDIR (
  set "VSROOT=%VSINSTALLDIR%"
) else (
  set "VSROOT=$installpath$..\..\"
)

set "LLVM_BIN=%VSROOT%VC\Tools\Llvm\bin"
set "CLANGCL_EXE=%LLVM_BIN%\clang-cl.exe"
set "ENV_CACHE=%BUILD_DIR%\.msvc_env.cmd"
set "NEEDS_VCVARS="

if /i "%TOOLCHAIN%"=="msvc"  set "NEEDS_VCVARS=1"
if /i "%TOOLCHAIN%"=="clang" set "NEEDS_VCVARS=1"

if defined NEEDS_VCVARS (
  set "NEED_INIT=0"
  if /i "%TOOLCHAIN%"=="msvc" (
    where cl >nul 2>nul || set "NEED_INIT=1"
  ) else if /i "%TOOLCHAIN%"=="clang" (
    where clang-cl >nul 2>nul || set "NEED_INIT=1"
  )

  if "!NEED_INIT!"=="1" (
    if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%" >nul 2>nul

    if exist "%ENV_CACHE%" (
      call "%ENV_CACHE%"
    ) else (
      if not exist "!VCVARSALL_BAT!" (
        where "!VCVARSALL_BAT!" >nul 2>nul || (
          set "VCVARSALL_BAT=%VSROOT%VC\Auxiliary\Build\vcvarsall.bat"
          if not exist "!VCVARSALL_BAT!" (
            echo ERROR: MSVC not initialized. Set VCVARSALL_BAT in env\local.env or run from a VS Dev Prompt.
            exit /b 1
          )
        )
      )

      echo Initializing MSVC environment ...
      call "!VCVARSALL_BAT!" %VCARCH% || exit /b 1

      where cl >nul 2>nul || (
        echo ERROR: cl not found after calling vcvarsall
        exit /b 1
      )
      (
        for /f "delims=" %%L in ('set') do echo set "%%L"
      ) > "%ENV_CACHE%"
    )
  )
  where cl >nul 2>nul || (
    echo ERROR: cl not found after loading MSVC environment
    exit /b 1
  )
  if /i "%TOOLCHAIN%"=="clang" (
    where clang-cl >nul 2>nul || (
      if exist "%CLANGCL_EXE%" (
        set "PATH=%LLVM_BIN%;%PATH%"
      )
    )
    where clang-cl >nul 2>nul || (
      echo ERROR: clang-cl not found. Expected at: "%CLANGCL_EXE%"
      exit /b 1
    )
  )
)

rem ============================================================
rem Resolve CMake (PATH first, VS fallback)
rem ============================================================
if not exist "!CMAKE_EXE!" (
  where "!CMAKE_EXE!" >nul 2>nul || (
    set "CMAKE_EXE=%VSROOT%Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
    if not exist "!CMAKE_EXE!" (
      echo ERROR: CMake not found. Set CMAKE_EXE in env\local.env
      exit /b 1
    )
  )
)

rem ============================================================
rem Ninja availability (PATH-based, no -DCMAKE_MAKE_PROGRAM)
rem ============================================================
if defined CMAKE_MAKE_PROGRAM (
  if not exist "!CMAKE_MAKE_PROGRAM!" (
    where "!CMAKE_MAKE_PROGRAM!" >nul 2>nul || (
      set "CMAKE_MAKE_PROGRAM=%VSROOT%Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
      if not exist "!CMAKE_MAKE_PROGRAM!" (
        echo ERROR: Ninja not found. Set CMAKE_MAKE_PROGRAM in env\local.env
        exit /b 1
      )
    )
  )

  for %%P in ("!CMAKE_MAKE_PROGRAM!") do set "PATH=%%~dpP;%PATH%"
)
where ninja >nul 2>nul || (
  echo ERROR: Ninja not found on PATH.
  exit /b 1
)

rem ============================================================
rem Configure
rem ============================================================
set "SENTINEL=%BUILD_DIR%\.configured.snt"

if not exist "%SENTINEL%" (
  "%CMAKE_EXE%" -S . -B "%BUILD_DIR%" ^
      -G "%BUILD_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" ^
      -DCMAKE_BUILD_TYPE=%FLAVOR% ^
      -DCMAKE_C_COMPILER=%CMAKE_C_COMPILER% ^
      -DCMAKE_CXX_COMPILER=%CMAKE_CXX_COMPILER% ^
      %EXTRA_CMAKE_ARGS%

  copy /y nul "%SENTINEL%" >nul
)

rem ============================================================
rem Build
rem ============================================================
"%CMAKE_EXE%" --build "%BUILD_DIR%" %EXTRA_CMAKE_BUILD_ARGS%
if errorlevel 1 goto :error

rem ============================================================
rem Install
rem ============================================================
"%CMAKE_EXE%" --install "%BUILD_DIR%" --config %FLAVOR%
if errorlevel 1 goto :error
goto :eof

rem ============================================================
rem Functions
rem ============================================================
:load_env
if not exist "%~1" goto :eof
for /f "usebackq tokens=1* delims==" %%A in ("%~1") do (
  if not "%%A"=="" set "%%A=%%B"
)
goto :eof

rem ============================================================
rem Error
rem ============================================================
:error
echo ERROR: build failed.
exit /b 1
