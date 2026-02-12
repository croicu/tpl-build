cmake_minimum_required(VERSION 3.20)
project(CppModuleHost LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(CppModuleHost
    main.cpp
)

target_link_libraries(CppModuleHost PRIVATE $safeprojectname$)

install(TARGETS CppModuleHost
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(MSVC)
    install(FILES $<TARGET_PDB_FILE:CppModuleHost>
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        OPTIONAL
    )
endif()
