rem ============================================================
rem Clean (CMake)
rem ============================================================
"%CMAKE_EXE%" --build "%BUILD_DIR%" --target clean %EXTRA_CMAKE_BUILD_ARGS% 1>nul 2>nul

exit /b 0