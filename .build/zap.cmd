rmdir /s /q %BUILD_DIR% 1>nul 2>nul
rmdir /s /q %INSTALL_DIR% 1>nul 2>nul
rmdir /s /q out\%ARCH_DIR%\test 1>nul 2>nul

set "TESTS_DIR=tests"

rmdir /s /q %TESTS_DIR%\dotnet\.vs 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\TestResults 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\core\bin 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\core\obj 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\runner\bin 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\runner\obj 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\mstest\unit\bin 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\mstest\unit\obj 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\mstest\unit\TestResults 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\mstest\integration\bin 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\mstest\integration\obj 1>nul 2>nul
rmdir /s /q %TESTS_DIR%\dotnet\mstest\integration\TestResults 1>nul 2>nul

exit /b 0