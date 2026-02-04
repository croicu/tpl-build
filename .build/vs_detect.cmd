rem ============================================================
rem Toolchain detection 
rem ============================================================
if defined VSINSTALLDIR (
  set "VSROOT=%VSINSTALLDIR%"
) else (
  set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
  if exist "%VSWHERE%" (
    for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -property installationPath`) do set "VSROOT=%%I\"
  )
)

exit /b 0