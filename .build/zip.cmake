# .build/Zip.cmake
# Generic helpers to zip “payload folders as data” using: cmake -E tar --format=zip
#
# Conventions:
# - You call templates_zip_init(PACK_NAME <...> OUT_BUILD_ROOT <var> [AGGREGATE_TARGET <tgt>])
# - You call templates_add_payload_zip(REL_DIR <...> BUILD_ROOT <...> [TARGET_PREFIX <...>])
#
# REL_DIR is relative to the caller CMakeLists.txt directory (dispatcher-friendly).
# Zip contains the *contents* of the payload folder, not the folder itself.

function(templates_zip_init)
  set(oneValueArgs PACK_NAME OUT_BUILD_ROOT AGGREGATE_TARGET)
  cmake_parse_arguments(TZI "" "${oneValueArgs}" "" ${ARGN})

  if(NOT TZI_PACK_NAME)
    message(FATAL_ERROR "templates_zip_init: PACK_NAME is required")
  endif()
  if(NOT TZI_OUT_BUILD_ROOT)
    message(FATAL_ERROR "templates_zip_init: OUT_BUILD_ROOT (var name) is required")
  endif()

  # Default aggregate target name: <pack>_templates_zip
  set(_agg "${TZI_PACK_NAME}_templates_zip")
  if(TZI_AGGREGATE_TARGET)
    set(_agg "${TZI_AGGREGATE_TARGET}")
  endif()

  if(NOT TARGET ${_agg})
    add_custom_target(${_agg})
  endif()

  # Produce ZIPs under the TOP build tree (works well with add_subdirectory).
  # e.g. build/x64/Debug/templates/cpp/...
  set(_build_root "${CMAKE_BINARY_DIR}/templates/${TZI_PACK_NAME}")

  set(${TZI_OUT_BUILD_ROOT} "${_build_root}" PARENT_SCOPE)
  set(TEMPLATES_ZIP_AGGREGATE_TARGET "${_agg}" PARENT_SCOPE)
endfunction()

function(templates_add_payload_zip)
  set(oneValueArgs PACK_NAME REL_DIR BUILD_ROOT TARGET_PREFIX AGGREGATE_TARGET)
  cmake_parse_arguments(TAPZ "" "${oneValueArgs}" "" ${ARGN})

  if(NOT TAPZ_PACK_NAME)
    message(FATAL_ERROR "templates_add_payload_zip: PACK_NAME is required")
  endif()
  if(NOT TAPZ_REL_DIR)
    message(FATAL_ERROR "templates_add_payload_zip: REL_DIR is required")
  endif()
  if(NOT TAPZ_BUILD_ROOT)
    message(FATAL_ERROR "templates_add_payload_zip: BUILD_ROOT is required")
  endif()

  # Aggregate target (optional; defaults to what templates_zip_init() published)
  set(_agg "${TEMPLATES_ZIP_AGGREGATE_TARGET}")
  if(TAPZ_AGGREGATE_TARGET)
    set(_agg "${TAPZ_AGGREGATE_TARGET}")
  endif()

  # Payload folder is data; resolve relative to the calling CMakeLists.txt
  set(payload_root "${CMAKE_CURRENT_LIST_DIR}/${TAPZ_REL_DIR}")
  if(NOT IS_DIRECTORY "${payload_root}")
    message(FATAL_ERROR "Template payload root not found: ${payload_root}")
  endif()

  # Track payload files for incremental rebuilds.
  # CONFIGURE_DEPENDS forces CMake to re-run when files are added/removed.
  file(GLOB_RECURSE _payload_files CONFIGURE_DEPENDS
    "${payload_root}/*"
  )

  # "console/project" -> "console.project"
  string(REPLACE "/" "." rel_dotted "${TAPZ_REL_DIR}")

  # Final filename: <pack>.<rel_dotted>.zip  e.g. cpp.console.project.zip
  set(zip_name "${TAPZ_PACK_NAME}.${rel_dotted}.zip")
  set(zip_out_dir "${TAPZ_BUILD_ROOT}")
  set(zip_out     "${zip_out_dir}/${zip_name}")
  
  # Target naming
  set(prefix "template_zip")
  if(TAPZ_TARGET_PREFIX)
    set(prefix "${TAPZ_TARGET_PREFIX}")
  endif()
  string(REPLACE "/" "." _safe_rel "${TAPZ_REL_DIR}")
  set(tgt "${prefix}.${TAPZ_PACK_NAME}.${_safe_rel}")

  add_custom_command(
    OUTPUT "${zip_out}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${zip_out_dir}"
    COMMAND "${CMAKE_COMMAND}" -E rm -f "${zip_out}"
    COMMAND "${CMAKE_COMMAND}" -E tar cf "${zip_out}" --format=zip -- .
    WORKING_DIRECTORY "${payload_root}"
    DEPENDS ${_payload_files}
    VERBATIM
  )

  add_custom_target("${tgt}" DEPENDS "${zip_out}")

  if(_agg AND TARGET ${_agg})
    add_dependencies("${_agg}" "${tgt}")
  endif()

  get_filename_component(_zip_name "${zip_out}" NAME)   # zip_out = full path to zip output
  set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_URLS "${_zip_name}")

  # Install: <prefix>/templates/<zip_name>
  install(FILES "${zip_out}" DESTINATION "templates")
endfunction()

function(templates_write_manifest out_file)
  get_property(_urls GLOBAL PROPERTY TPL_MANIFEST_URLS)
  if(NOT _urls)
    message(FATAL_ERROR "templates_write_manifest: no zips were registered")
  endif()

  file(WRITE "${out_file}" "{\n  \"assets\": [\n")

  set(_first TRUE)
  foreach(u IN LISTS _urls)
    if(NOT _first)
      file(APPEND "${out_file}" ",\n")
    endif()
    file(APPEND "${out_file}" "    {\"url\": \"${u}\"}")
    set(_first FALSE)
  endforeach()

  file(APPEND "${out_file}" "\n  ]\n}\n")
endfunction()