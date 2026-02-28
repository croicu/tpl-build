# .build/Zip.cmake
# Zip “payload folders as data” using: cmake -E tar --format=zip
#
# Public API:
#   templates_add_payload_zip(TEMPLATE_SOURCE_DIR <rel> TARGET_ALIAS <name>)
#   templates_write_manifest(<out_file>)
#
# Conventions:
# - TEMPLATE_SOURCE_DIR is relative to the caller CMakeLists.txt directory.
# - Zip contains the *contents* of the payload folder, not the folder itself.
# - A single aggregate target is created automatically: templates_zip (ALL)
# - Output ZIPs go under: ${CMAKE_BINARY_DIR}/templates/
# - install() goes to: templates/

function(_templates_zip_ensure_init)
    # Aggregate target for all template ZIPs.
    if(NOT TARGET templates_zip)
        add_custom_target(templates_zip ALL)
    endif()

    # Where we emit ZIPs.
    if(NOT DEFINED TEMPLATES_ZIP_BUILD_ROOT)
        set(TEMPLATES_ZIP_BUILD_ROOT "${CMAKE_BINARY_DIR}/templates" CACHE PATH
            "Build output root for template ZIPs")
    endif()

    set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_IDS    "${internal_id}")
    set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_NAMES  "${user_name}")
    set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_ASSETS "${zip_name}")
endfunction()

function(templates_add_payload_zip)
    set(oneValueArgs TEMPLATE_SOURCE_DIR TARGET_ALIAS)
    cmake_parse_arguments(TAPZ "" "${oneValueArgs}" "" ${ARGN})

    if(NOT TAPZ_TEMPLATE_SOURCE_DIR)
        message(FATAL_ERROR "templates_add_payload_zip: TEMPLATE_SOURCE_DIR is required")
    endif()

    _templates_zip_ensure_init()

    # Resolve payload folder relative to the calling CMakeLists.txt
    set(payload_root "${CMAKE_CURRENT_LIST_DIR}/${TAPZ_TEMPLATE_SOURCE_DIR}")
    if(NOT IS_DIRECTORY "${payload_root}")
        message(FATAL_ERROR "Template payload root not found: ${payload_root}")
    endif()

    set(internal_id "${TAPZ_TEMPLATE_SOURCE_DIR}")
    file(TO_CMAKE_PATH "${internal_id}" internal_id)
    string(REPLACE "/" "-" internal_id "${internal_id}")

    if(NOT internal_id MATCHES "^[A-Za-z0-9_-]+$")
        message(FATAL_ERROR
            "Invalid internal id '${internal_id}' derived from '${TAPZ_TEMPLATE_SOURCE_DIR}'")
    endif()

    set(user_name "_")
    if(TAPZ_TARGET_ALIAS)
        set(user_name "${TAPZ_TARGET_ALIAS}")

        if(NOT user_name MATCHES "^[A-Za-z0-9_-]+$")
            message(FATAL_ERROR "Invalid TARGET_ALIAS '${user_name}'")
        endif()
    endif()

    # Track payload files for incremental rebuilds.
    file(GLOB_RECURSE _payload_files CONFIGURE_DEPENDS
        "${payload_root}/*"
    )

    # Enforce unique internal_id inside this build.
    get_property(_aliases GLOBAL PROPERTY TPL_MANIFEST_ALIASES)
    if(_aliases)
        list(FIND _aliases "${internal_id}" _alias_idx)
        if(NOT _alias_idx EQUAL -1)
            message(FATAL_ERROR "Duplicate name '${internal_id}' (collision)")
        endif()
    endif()

    set(zip_name    "${PROJECT_NAME}-${internal_id}")
    set(zip_out_dir "${TEMPLATES_ZIP_BUILD_ROOT}")
    set(zip_out     "${zip_out_dir}/${zip_name}.zip")

    set(tgt "template_zip.${internal_id}")

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
    add_dependencies(templates_zip "${tgt}")

    install(FILES "${zip_out}" DESTINATION "templates")

    set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_ALIASES "${internal_id}")
    set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_ASSETS  "${zip_name}")
    set_property(GLOBAL APPEND PROPERTY TPL_MANIFEST_NAMES   "${user_name}")
endfunction()

function(templates_write_manifest out_file)
    if(NOT out_file)
        message(FATAL_ERROR "templates_write_manifest: out_file is required")
    endif()

    get_property(_aliases GLOBAL PROPERTY TPL_MANIFEST_ALIASES)
    get_property(_assets  GLOBAL PROPERTY TPL_MANIFEST_ASSETS)
    get_property(_names   GLOBAL PROPERTY TPL_MANIFEST_NAMES)

    list(LENGTH _aliases _n_aliases)
    list(LENGTH _assets  _n_assets)
    list(LENGTH _names   _n_names)
    if(NOT _n_aliases EQUAL _n_assets OR NOT _n_aliases EQUAL _n_names)
        message(FATAL_ERROR "templates_write_manifest: internal manifest lists are inconsistent")
    endif()

    file(WRITE  "${out_file}" "{\n")
    file(APPEND "${out_file}" "  \"schema\": 1,\n")
    file(APPEND "${out_file}" "  \"assets\": [\n")

    set(_first TRUE)
    math(EXPR _last "${_n_aliases} - 1")
    foreach(_template RANGE 0 ${_last})
        list(GET _aliases ${_template} alias)
        list(GET _assets  ${_template} asset)
        list(GET _names   ${_template} name)

        if(NOT _first)
            file(APPEND "${out_file}" ",\n")
        endif()

        file(APPEND "${out_file}" "    \"${asset}\"")
        set(_first FALSE)
    endforeach()

    file(APPEND "${out_file}" "\n  ]\n}\n")
endfunction()