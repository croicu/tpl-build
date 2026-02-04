cmake_minimum_required(VERSION 3.10)
project(templates_dispatch LANGUAGES NONE)

include("${PROJECT_ROOT}/.build/dispatch.cmake")

add_subproject(NAME cpp SOURCE_DIR "cpp" ADD_TO_ALL  ON)