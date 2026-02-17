cmake_minimum_required(VERSION 3.20)
project(CppLibraryHost LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(CppLibraryHost
    main.cpp
)

target_link_libraries(CppLibraryHost PRIVATE $safeprojectname$)

install(TARGETS CppLibraryHost
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(MSVC)
    install(FILES $<TARGET_PDB_FILE:CppLibraryHost>
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        OPTIONAL
    )
endif()
