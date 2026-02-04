# .build/dispatch.cmake
# Dispatch to child CMake projects.
# Forwards:
#   -DPROJECT_ROOT=<root>
#   -DCMAKE_INSTALL_PREFIX=<same as parent>
#   -DCMAKE_BUILD_TYPE (only if set; good for Ninja)

if(NOT DEFINED PROJECT_ROOT OR PROJECT_ROOT STREQUAL "")
  get_filename_component(_cmake_dir "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY) # <root>/cmake
  get_filename_component(PROJECT_ROOT "${_cmake_dir}" DIRECTORY)            # <root>
endif()

# Auto-initialize a default aggregate target unless the includer opts out.
if(NOT DEFINED DISABLE_AUTO_INIT OR NOT DISABLE_AUTO_INIT)
  if(NOT DEFINED ALL_TARGET OR ALL_TARGET STREQUAL "")
    set(ALL_TARGET "all_artifacts" CACHE INTERNAL "Aggregate meta target name")
  endif()

  if(NOT TARGET ${ALL_TARGET})
    add_custom_target(${ALL_TARGET} ALL)
  endif()
endif()

function(_compute_child_args out_bt_args out_gen_args)
  set(bt_args "")
  set(gen_args "")

  # Only meaningful for single-config generators (e.g. Ninja)
  get_property(_is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(NOT _is_multi_config AND DEFINED CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "")
    list(APPEND bt_args "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  endif()

  # Helps keep nested Ninja consistent if the parent was given a specific ninja.exe
  if(DEFINED CMAKE_MAKE_PROGRAM AND NOT CMAKE_MAKE_PROGRAM STREQUAL "")
    list(APPEND gen_args "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
  endif()

  set(${out_bt_args} "${bt_args}" PARENT_SCOPE)
  set(${out_gen_args} "${gen_args}" PARENT_SCOPE)
endfunction()

function(init)
  set(oneValueArgs ALL_TARGET)
  cmake_parse_arguments(MI "" "${oneValueArgs}" "" ${ARGN})

  set(_all "all_artifacts")
  if(MI_ALL_TARGET)
    set(_all "${MI_ALL_TARGET}")
  endif()

  if(NOT TARGET ${_all})
    add_custom_target(${_all} ALL)
  endif()

  set(ALL_TARGET "${_all}" CACHE INTERNAL "Aggregate meta target name")
endfunction()

function(add_subproject)
  set(oneValueArgs NAME SOURCE_DIR BINARY_DIR ADD_TO_ALL)
  cmake_parse_arguments(MSP "" "${oneValueArgs}" "" ${ARGN})

  if(NOT MSP_NAME)
    message(FATAL_ERROR "add_subproject: NAME is required")
  endif()
  if(NOT MSP_SOURCE_DIR)
    message(FATAL_ERROR "add_subproject: SOURCE_DIR is required")
  endif()

  # Resolve SOURCE_DIR relative to *this* CMakeLists.txt (dispatcher-friendly).
  if(IS_ABSOLUTE "${MSP_SOURCE_DIR}")
    set(src "${MSP_SOURCE_DIR}")
  else()
    set(src "${CMAKE_CURRENT_LIST_DIR}/${MSP_SOURCE_DIR}")
  endif()

  # Default binary dir under the current dispatcher build tree.
  # This still yields separate binary dirs per subproject, but inside ONE build graph.
  if(MSP_BINARY_DIR)
    if(IS_ABSOLUTE "${MSP_BINARY_DIR}")
      set(bin "${MSP_BINARY_DIR}")
    else()
      set(bin "${CMAKE_CURRENT_BINARY_DIR}/${MSP_BINARY_DIR}")
    endif()
  else()
    set(bin "${CMAKE_CURRENT_BINARY_DIR}/${MSP_NAME}")
  endif()

  # Default: add to "ALL"
  if(NOT DEFINED MSP_ADD_TO_ALL OR MSP_ADD_TO_ALL STREQUAL "")
    set(MSP_ADD_TO_ALL "ON")
  endif()

  # Normalize ON/OFF-ish values.
  string(TOUPPER "${MSP_ADD_TO_ALL}" _add_to_all)

  # build PROJECT_ROOT visible to the subtree (it is not a cache var here; it's normal scope).
  # Child lists can read PROJECT_ROOT directly.
  set(PROJECT_ROOT "${PROJECT_ROOT}")

  # Add the subtree to the current build graph.
  if(_add_to_all STREQUAL "ON" OR _add_to_all STREQUAL "TRUE" OR _add_to_all STREQUAL "1" OR _add_to_all STREQUAL "YES")
    add_subdirectory("${src}" "${bin}")
  else()
    add_subdirectory("${src}" "${bin}" EXCLUDE_FROM_ALL)
  endif()

  # Optional: if your top-level uses an aggregate ALL_TARGET, keep that wiring.
  # This only works if the subtree defines a target with the same name as MSP_NAME.
  if(_add_to_all STREQUAL "ON" OR _add_to_all STREQUAL "TRUE" OR _add_to_all STREQUAL "1" OR _add_to_all STREQUAL "YES")
    if(DEFINED ALL_TARGET AND TARGET ${ALL_TARGET})
      if(TARGET ${MSP_NAME})
        add_dependencies(${ALL_TARGET} ${MSP_NAME})
      endif()
    endif()
  endif()
endfunction()
