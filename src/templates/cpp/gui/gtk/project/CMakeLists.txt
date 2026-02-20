# CMakeList.txt : CMake project
cmake_minimum_required(VERSION 3.20)
project ($safeprojectname$ LANGUAGES CXX)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK4 REQUIRED IMPORTED_TARGET gtk4)

add_executable($safeprojectname$)
include(.cmake/sources.generated.cmake OPTIONAL)

set_property(TARGET $safeprojectname$ PROPERTY CXX_STANDARD 20)

target_link_libraries($safeprojectname$ PRIVATE PkgConfig::GTK4)

install(TARGETS $safeprojectname$ 
  RUNTIME DESTINATION bin
)
