# CMakeList.txt : CMake project
cmake_minimum_required(VERSION 3.20)

project($safeprojectname$ LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)

add_library($safeprojectname$ SHARED)
include(.cmake/sources.generated.cmake OPTIONAL)

target_include_directories($safeprojectname$
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(TARGETS $safeprojectname$ 
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_BINDIR}   # keep next to exe
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)
