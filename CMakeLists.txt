# CMakeLists.txt

cmake_minimum_required(VERSION 3.20)
project(tpl_build LANGUAGES NONE)

set(PROJECT_ROOT "${CMAKE_SOURCE_DIR}")
include("${PROJECT_ROOT}/.build/dispatch.cmake")

add_subproject(NAME templates SOURCE_DIR  "src/templates" ADD_TO_ALL  ON)
