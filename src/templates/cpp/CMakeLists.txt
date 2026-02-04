cmake_minimum_required(VERSION 3.10)
project(templates_cpp LANGUAGES NONE)

include("${PROJECT_ROOT}/.build/Zip.cmake")

# Aggregate target for all C++ template ZIPs.
add_custom_target(cpp_templates_zip ALL)
templates_zip_init(PACK_NAME cpp OUT_BUILD_ROOT cpp_zip_build_root AGGREGATE_TARGET cpp_templates_zip)

# Aggregate clean target for all C++ template ZIPs.
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${cpp_zip_build_root}")

templates_add_payload_zip(PACK_NAME cpp REL_DIR "console/project"  BUILD_ROOT "${cpp_zip_build_root}" TARGET_PREFIX "cpp")
templates_add_payload_zip(PACK_NAME cpp REL_DIR "module/project"   BUILD_ROOT "${cpp_zip_build_root}" TARGET_PREFIX "cpp")
templates_add_payload_zip(PACK_NAME cpp REL_DIR "library/project"  BUILD_ROOT "${cpp_zip_build_root}" TARGET_PREFIX "cpp")
templates_add_payload_zip(PACK_NAME cpp REL_DIR "win32/project"    BUILD_ROOT "${cpp_zip_build_root}" TARGET_PREFIX "cpp")
