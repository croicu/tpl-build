# CMakeList.txt : CMake project
cmake_minimum_required(VERSION 3.20)
project ($safeprojectname$ LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

add_executable($safeprojectname$)
include(.cmake/sources.generated.cmake OPTIONAL)

set_property(TARGET $safeprojectname$ PROPERTY CXX_STANDARD 20)

target_link_libraries($safeprojectname$ PRIVATE Qt6::Widgets)

install(TARGETS $safeprojectname$ 
  RUNTIME DESTINATION bin
)
