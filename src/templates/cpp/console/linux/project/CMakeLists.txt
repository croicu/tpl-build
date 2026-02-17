# CMakeList.txt : CMake project
cmake_minimum_required(VERSION 3.20)
project($safeprojectname$ LANGUAGES CXX)

add_executable($safeprojectname$)
include(.cmake/sources.generated.cmake OPTIONAL)

set_property(TARGET $safeprojectname$ PROPERTY CXX_STANDARD 20)

install(TARGETS $safeprojectname$ 
  RUNTIME DESTINATION bin
)
