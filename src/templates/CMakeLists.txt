cmake_minimum_required(VERSION 3.20)
project(templates_dispatch LANGUAGES NONE)

include("${PROJECT_ROOT}/.build/dispatch.cmake")
include("${PROJECT_ROOT}/.build/zip.cmake")

add_subproject(NAME cpp SOURCE_DIR "cpp" ADD_TO_ALL  ON)

set(manifest_out "${CMAKE_BINARY_DIR}/manifest.json")

templates_write_manifest("${manifest_out}")
install(FILES "${manifest_out}" DESTINATION "${CMAKE_INSTALL_PREFIX}")