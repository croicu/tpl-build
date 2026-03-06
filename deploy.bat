@echo off
rem ============================================================
rem deploy.bat
rem Usage:
rem   deploy.bat where [debug|release] [x64|x86|arm]
rem Defaults:
rem   debug x64
rem ============================================================
setlocal EnableExtensions EnableDelayedExpansion

set "COMMAND=deploy"
set "FLAVOR=debug"
set "ARCH=x64"

set "WHERE=%~1" & shift
if "%WHERE%"=="" (
    echo ERROR: Missing destination argument: deploy.bat where
    goto :error
)

:loop
if "%~1"=="" goto after
  set "TAIL=%TAIL% %~1" & shift
goto loop
:after

call .build\args_parse.cmd %TAIL% || goto :error

set "INSTALL_DIR=out\%ARCH%\%FLAVOR%"
if not exist "%INSTALL_DIR%" (
  echo ERROR: Install directory not found: %INSTALL_DIR%
  goto :error
)

rem Deploy
if /i "%COMMAND%"=="deploy" (
  robocopy "%INSTALL_DIR%"            "\\%WHERE%\WWW\tpl-build" manifest.json /R:0 1>nul || goto :error
  robocopy "%INSTALL_DIR%\templates"  "\\%WHERE%\WWW\tpl-build" *.zip /R:0 1>nul || goto :error
  echo Deployment successful.
  goto :eof
)

:error
echo ERROR: deploy failed.
exit /b 1
