# CMakeList.txt : CMake project

cmake_minimum_required (VERSION 3.10)
project ("$safeprojectname$")

add_executable ($safeprojectname$)
include(.cmake/sources.generated.cmake OPTIONAL)

set_property(TARGET $safeprojectname$ PROPERTY CXX_STANDARD 20)

install(TARGETS $safeprojectname$ 
  RUNTIME DESTINATION bin
)
if (MSVC)
    install(FILES $<TARGET_PDB_FILE:$safeprojectname$> DESTINATION bin OPTIONAL)
endif()
