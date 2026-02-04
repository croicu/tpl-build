@echo off
setlocal EnableExtensions EnableDelayedExpansion

:parse
if "%~1"=="" goto :parsed

set "ARG=%~1"

if /i "%ARG%"=="debug"    set "CONFIG=debug"   & shift & goto :parse
if /i "%ARG%"=="release"  set "CONFIG=release" & shift & goto :parse

if /i "%ARG%"=="x64"      set "ARCH=x64" & shift & goto :parse
if /i "%ARG%"=="x86"      set "ARCH=x86" & shift & goto :parse

echo ERROR: Unknown argument: %ARG%
exit /b 1
:parsed

if "%ARCH%"=="" (
  echo ERROR: ARCH not set
  exit /b 1
)

if "%CONFIG%"=="" (
  echo ERROR: CONFIG not set
  exit /b 1
)

if not defined VCToolsInstallDir (
  for /f "usebackq delims=" %%I in (`
    "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" ^
      -latest ^
      -products * ^
      -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
      -property installationPath`) do set VSINSTALLDIR=%%I\

  if "!VSINSTALLDIR!"=="" (
    echo ERROR: MSVC Build Tools not found
    exit /b 1
  )
  call "!VSINSTALLDIR!\VC\Auxiliary\Build\vcvarsall.bat" %ARCH%
    if errorlevel 1 exit /b %errorlevel%
)

set WS_ROOT=%CD%

if not defined BUILD_DIR (
  set "BUILD_DIR=%WS_ROOT%\build\%ARCH%\%CONFIG%"
)
if not exist "%BUILD_DIR%" (
  mkdir "%BUILD_DIR%"
)

if not defined INSTALL_DIR (
  set "INSTALL_DIR=%WS_ROOT%\out\%ARCH%\%CONFIG%"
)
if not exist "%INSTALL_DIR%" (
  mkdir "%INSTALL_DIR%"
)

set "BUILD_GENERATOR=Ninja"
set "CMAKE_EXE=cmake"
set "CMAKE_MAKE_PROGRAM=ninja"
set "CMAKE_C_COMPILER=cl"
set "CMAKE_CXX_COMPILER=cl"

"%CMAKE_EXE%" ^
  -S "%WS_ROOT%" ^
  -B "%BUILD_DIR%" ^
  -G "%BUILD_GENERATOR%" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" ^
  -DCMAKE_BUILD_TYPE=%CONFIG%
if errorlevel 1 exit /b %errorlevel%

"%CMAKE_EXE%" --build "%BUILD_DIR%"
if errorlevel 1 exit /b %errorlevel%

"%CMAKE_EXE%" --install "%BUILD_DIR%"
if errorlevel 1 exit /b %errorlevel%

exit /b 0
