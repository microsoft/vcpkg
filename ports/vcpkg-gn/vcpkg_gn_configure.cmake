include_guard(GLOBAL)

function(z_vcpkg_gn_configure_generate)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH;CONFIG;ARGS" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Internal error: generate was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    message(STATUS "Generating build (${arg_CONFIG})...")
    vcpkg_execute_required_process(
        COMMAND "${GN}" gen "${CURRENT_BUILDTREES_DIR}/${arg_CONFIG}" "${arg_ARGS}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        LOGNAME "generate-${arg_CONFIG}"
    )
endfunction()

function(vcpkg_gn_configure)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH;OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_gn_configure was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()

    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")

    vcpkg_find_acquire_program(GN)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_gn_configure_generate(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            CONFIG "${TARGET_TRIPLET}-dbg"
            ARGS "--args=${arg_OPTIONS} ${arg_OPTIONS_DEBUG}"
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_gn_configure_generate(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            CONFIG "${TARGET_TRIPLET}-rel"
            ARGS "--args=${arg_OPTIONS} ${arg_OPTIONS_RELEASE}"
        )
    endif()
endfunction()
