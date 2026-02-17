rem ============================================================
rem Argument parsing.
rem ============================================================

:parse
if "%~1"=="" goto :parsed

set "ARG=%~1"

if /i "%ARG%"=="build"    set "COMMAND=build"    & shift & goto :parse
if /i "%ARG%"=="rebuild"  set "COMMAND=rebuild"  & shift & goto :parse
if /i "%ARG%"=="clean"    set "COMMAND=clean"    & shift & goto :parse
if /i "%ARG%"=="zap"      set "COMMAND=zap"      & shift & goto :parse
if /i "%ARG%"=="register" set "COMMAND=register" & shift & goto :parse
if /i "%ARG%"=="test"     set "COMMAND=test"     & shift & goto :parse

if /i "%ARG%"=="debug"    set "FLAVOR=debug"   & shift & goto :parse
if /i "%ARG%"=="release"  set "FLAVOR=release" & shift & goto :parse
if /i "%ARG%"=="ship"     set "FLAVOR=release" & shift & goto :parse

if /i "%ARG%"=="x64"      set "ARCH=x64" & shift & goto :parse
if /i "%ARG%"=="x86"      set "ARCH=x86" & shift & goto :parse

if /i "%ARG%"=="msvc"     set "TOOLCHAIN=msvc"  & shift & goto :parse
if /i "%ARG%"=="clang"    set "TOOLCHAIN=clang" & shift & goto :parse

if /i "%ARG%"=="--experimental" (
  set "EXPERIMENTAL=1"
  shift
  goto :parse
)

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

exit /b 0