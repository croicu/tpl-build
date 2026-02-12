# VSIX Template

### VSIX Custom Wizard

https://learn.microsoft.com/en-us/visualstudio/extensibility/how-to-use-wizards-with-project-templates?view=visualstudio


### VS User Template Folder
%ONEDRIVE%\Documents\Visual Studio 18\Templates\ProjectTemplates
### VS Template Cache
%LOCALAPPDATA%\Microsoft\VisualStudio\18.0_a2585876Exp\Extensions
%LOCALAPPDATA%\Microsoft\VisualStudio\18.0_a2585876Exp\Extensions\Croicu\Croicu.Build.Templates.CMake\1.0\ProjectTemplates\VC\1033\Console\Console.vstemplate
### VS Log
%APPDATA%\Microsoft\VisualStudio\18.0_a2585876Exp\ActivityLog.xml
### VS Stock Project Templates Folder
C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\ProjectTemplates
### VS Where:
C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe
### VC vars All
C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat
### VS Logging:
devenv /RootSuffix Exp /log

### Power Shell
```
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```
### TestHost

## Tasks:
- Template incremental build test.
- Library Project.
- Library Host.
- Win32 GUI Project.
- Linus GUI Project.
- Root VS solution.
- Test harness adapter as a shared module used for creating the LocalContext during test method invocation.
- VSIX package for syncing the project with 
## Issues:
- Incremental build is broken when updating the project template.
- Rebuild is broken when changing the project template.

## cpp project tree
```
C:.
└───cpp
    │   CMakeLists.txt
    │
    ├───console
    │   │   CMakeLists.txt
    │   │
    │   └───project
    │       │   CMakeLists.txt
    │       │   Console.ico
    │       │   Console.vcxproj
    │       │   Console.vcxproj.filters
    │       │   Console.vstemplate
    │       │   CppConsole.csproj
    │       │   build.bat
    │       │   build.sh
    │       │
    │       ├───.build
    │       │       sources.generated.cmake
    │       │
    │       ├───.vscode
    │       │       launch.json
    │       │       settings.json
    │       │       tasks.json
    │       │
    │       └───src
    │               main.cpp
    │
    ├───gui
    │   │   CMakeLists.txt
    │   │
    │   └───project
    │       │   CMakeLists.txt
    │       │   Console.ico
    │       │   Console.vcxproj
    │       │   Console.vcxproj.filters
    │       │   Console.vstemplate
    │       │   CppConsole.csproj
    │       │   build.bat
    │       │   build.sh
    │       │
    │       ├───.build
    │       │       sources.generated.cmake
    │       │
    │       ├───.vscode
    │       │       launch.json
    │       │       settings.json
    │       │       tasks.json
    │       │
    │       └───src
    │               main.cpp
    │
    ├───library
    │   │   CMakeLists.txt
    │   │
    │   └───project
    │       │   CMakeLists.txt
    │       │   Console.ico
    │       │   Console.vcxproj
    │       │   Console.vcxproj.filters
    │       │   Console.vstemplate
    │       │   CppConsole.csproj
    │       │   build.bat
    │       │   build.sh
    │       │
    │       ├───.build
    │       │       sources.generated.cmake
    │       │
    │       ├───.vscode
    │       │       launch.json
    │       │       settings.json
    │       │       tasks.json
    │       │
    │       └───src
    │               main.cpp
    │
    └───module
        │   CMakeLists.txt
        │
        └───project
            │   CMakeLists.txt
            │   Console.ico
            │   Console.vcxproj
            │   Console.vcxproj.filters
            │   Console.vstemplate
            │   CppConsole.csproj
            │   build.bat
            │   build.sh
            │
            ├───.build
            │       sources.generated.cmake
            │
            ├───.vscode
            │       launch.json
            │       settings.json
            │       tasks.json
            │
            └───src
                    main.cpp
```