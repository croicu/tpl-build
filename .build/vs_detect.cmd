rem ============================================================
rem Toolchain detection 
rem ============================================================

if defined VSINSTALLDIR (
  set "VSROOT=%VSINSTALLDIR%"
  exit /b 0
)

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
  for /f "usebackq delims=" %%I in (`
    "%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
  `) do set "VSROOT=%%~I"
)

if defined VSROOT (
  if not "%VSROOT:~-1%"=="\" set "VSROOT=%VSROOT%\"
)

exit /b 0