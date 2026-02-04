rem ============================================================
rem Toolchain configuration (msvc + clang)
rem ============================================================
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
        set "VCVARSALL_BAT=%VSROOT%VC\Auxiliary\Build\vcvarsall.bat"
      )

      if not exist "!VCVARSALL_BAT!" (
        echo WARNING: vcvarsall not found. Compiled projects will be skipped.
        set "CMAKE_C_COMPILER="
        set "CMAKE_CXX_COMPILER="
        goto :toolchain_done
      )

      echo Initializing MSVC environment ...
      call "!VCVARSALL_BAT!" %VCARCH% || (
        echo WARNING: vcvarsall failed. Compiled projects will be skipped.
        set "CMAKE_C_COMPILER="
        set "CMAKE_CXX_COMPILER="
        goto :toolchain_done
      )

      where cl >nul 2>nul || (
        echo WARNING: cl not found after vcvarsall. Compiled projects will be skipped.
        set "CMAKE_C_COMPILER="
        set "CMAKE_CXX_COMPILER="
        goto :toolchain_done
      )

      call :env_cache_write "%ENV_CACHE%"
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

:toolchain_done
if not "%CMAKE_CXX_COMPILER%"=="" set "HAS_CXX=1"

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
if not exist "!CMAKE_MAKE_PROGRAM!" (
  where "!CMAKE_MAKE_PROGRAM!" >nul 2>nul || (
    set "CMAKE_MAKE_PROGRAM=%VSROOT%Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
    if not exist "!CMAKE_MAKE_PROGRAM!" (
      echo ERROR: Ninja not found. Set CMAKE_MAKE_PROGRAM in env\local.env
      exit /b 1
    )
  )
)

where ninja >nul 2>nul || (
  if defined CMAKE_MAKE_PROGRAM (
    for %%P in ("!CMAKE_MAKE_PROGRAM!") do set "PATH=%%~dpP;%PATH%"
  ) else (
    echo ERROR: Ninja not found on PATH.
    exit /b 1
  )
)

exit /b 0

:env_cache_write
set "ENV_CACHE=%~1"
if not defined ENV_CACHE (
  echo ERROR: env_cache_write: missing cache path
  exit /b 1
)

(
  for /f "tokens=1* delims==" %%A in ('set') do (
    set "NAME=%%A"
    set "ALLOW="

    rem Exact names
    if /i "!NAME!"=="INCLUDE" set "ALLOW=1"
    if /i "!NAME!"=="LIB" set "ALLOW=1"
    if /i "!NAME!"=="LIBPATH" set "ALLOW=1"
    if /i "!NAME!"=="Path" set "ALLOW=1"
    if /i "!NAME!"=="ExtensionSdkDir" set "ALLOW=1"
    if /i "!NAME!"=="UniversalCRTSdkDir" set "ALLOW=1"
    if /i "!NAME!"=="NETFXSDKDir" set "ALLOW=1"

    rem Prefix families
    if /i "!NAME:~0,5!"=="VSCMD" set "ALLOW=1"
    if /i "!NAME:~0,2!"=="VC" set "ALLOW=1"
    if /i "!NAME:~0,2!"=="VS" set "ALLOW=1"
    if /i "!NAME:~0,10!"=="WindowsSdk" set "ALLOW=1"
    if /i "!NAME:~0,10!"=="WindowsSDK" set "ALLOW=1"
    if /i "!NAME:~0,4!"=="UCRT" set "ALLOW=1"
    if /i "!NAME:~0,9!"=="Framework" set "ALLOW=1"

    if defined ALLOW echo set "%%A=%%B"
  )
) > "%ENV_CACHE%"

exit /b 0
