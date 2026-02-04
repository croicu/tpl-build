rem ============================================================
rem Register templates in Visual Studio (ZIP-only)
rem     Requires full Visual Studio (devenv.exe). Build Tools alone is not enough.
rem ============================================================

if not defined VSROOT (
  echo ERROR: Visual Studio not detected. Cannot register templates.
  exit /b 1
)

set "DEVENV=%VSROOT%Common7\IDE\devenv.exe"
if not exist "%DEVENV%" (
  echo ERROR: devenv.exe not found. Register requires full Visual Studio.
  exit /b 1
)

rem Determine VS major version from VSROOT (e.g. ...\Microsoft Visual Studio\18\Community\)
set "VSROOT_NO_SLASH=%VSROOT%"
if "%VSROOT_NO_SLASH:~-1%"=="\" set "VSROOT_NO_SLASH=%VSROOT_NO_SLASH:~0,-1%"

rem Extract Visual Studio major version (e.g. 18) from VSROOT
set "VS_MAJOR="
for /f "tokens=1 delims=\" %%A in ("%VSROOT_NO_SLASH:*\Microsoft Visual Studio\=%") do (
  set "VS_MAJOR=%%A"
)
echo(!VS_MAJOR!| findstr /r "^[0-9][0-9]*$" >nul || set "VS_MAJOR="

if "%VS_MAJOR%"=="" (
  echo ERROR: Could not determine Visual Studio major version from VSROOT: "%VSROOT%"
  exit /b 1
)

rem Read Documents path from registry (handles OneDrive Known Folder Move)
set "DOCS_DIR_RAW="
for /f "tokens=2,*" %%A in ('
  reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal 2^>nul ^| find /i "Personal"
') do (
  set "DOCS_DIR_RAW=%%B"
)
if "%DOCS_DIR_RAW%"=="" (
  echo ERROR: Unable to read Documents path from registry.
  exit /b 1
)

rem Expand environment variables inside the registry value
call set "DOCS_DIR=%DOCS_DIR_RAW%"
set "DOCS_DIR=%DOCS_DIR:"=%"
if "%DOCS_DIR%"=="" (
  echo ERROR: Documents path expansion failed. Raw value was: "%DOCS_DIR_RAW%"
  exit /b 1
)

rem Compute destination templates folder
set "TEMPLATES_SRC=%INSTALL_DIR%\templates"
if not exist "%TEMPLATES_SRC%" (
  echo ERROR: Template output folder not found: "%TEMPLATES_SRC%".
  exit /b 1
)

set "VS_DOCS_DIR=%DOCS_DIR%\Visual Studio %VS_MAJOR%"
set "TEMPLATES_DST=%VS_DOCS_DIR%\Templates\ProjectTemplates"
if not exist "%TEMPLATES_DST%" mkdir "%TEMPLATES_DST%" >nul 2>nul

echo Registering templates
echo   From: "%TEMPLATES_SRC%"
echo   To:   "%TEMPLATES_DST%"

rem Copy all .zip templates, preserving directory structure under templates/
robocopy "%TEMPLATES_SRC%" "%TEMPLATES_DST%" *.zip /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo ERROR: robocopy failed copying templates.
  exit /b 1
)

rem Refresh VS template cache (normal or experimental hive)
if "%EXPERIMENTAL%"=="1" (
  echo Refreshing Visual Studio Experimental template cache
  "%DEVENV%" /RootSuffix Exp /InstallVSTemplates >nul
) else (
  echo Refreshing Visual Studio template cache
  "%DEVENV%" /InstallVSTemplates >nul
)

exit /b 0
