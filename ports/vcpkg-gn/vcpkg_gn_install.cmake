include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_gn_real_path.cmake")

function(z_vcpkg_gn_install_get_target_type out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "SOURCE_PATH;BUILD_DIR;TARGET" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Internal error: get_target_type was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    execute_process(
        COMMAND "${VCPKG_GN}" desc "${arg_BUILD_DIR}" "${arg_TARGET}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(output MATCHES [[type: ([A-Za-z0-9_]+)]])
        set("${out_var}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "invalid result from `gn desc`: ${output}")
    endif()
endfunction()

function(z_vcpkg_gn_install_get_desc out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "SOURCE_PATH;BUILD_DIR;TARGET;WHAT_TO_DISPLAY" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Internal error: get_desc was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    execute_process(
        COMMAND "${VCPKG_GN}" desc "${arg_BUILD_DIR}" "${arg_TARGET}" "${arg_WHAT_TO_DISPLAY}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REPLACE ";" "\\;" output "${output}")
    string(REGEX REPLACE "\n|(\r\n)" ";" output "${output}")
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_gn_install_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH;BUILD_DIR;INSTALL_DIR" "TARGETS")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Internal error: install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(target IN LISTS arg_TARGETS)
        # GN targets must start with a //
        z_vcpkg_gn_install_get_desc(outputs
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${arg_BUILD_DIR}"
            TARGET "//${target}"
            WHAT_TO_DISPLAY outputs
        )
        z_vcpkg_gn_install_get_target_type(target_type
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${arg_BUILD_DIR}"
            TARGET "//${target}"
        )

        foreach(output IN LISTS outputs)
            if(output MATCHES "^//")
                # relative path (e.g. //out/Release/target.lib)
                string(REGEX REPLACE "^//" "${arg_SOURCE_PATH}/" output "${output}")
            elseif(output MATCHES "^/" AND CMAKE_HOST_WIN32)
                # absolute path (e.g. /C:/path/to/target.lib)
                string(REGEX REPLACE "^/" "" output "${output}")
            endif()

            if(NOT EXISTS "${output}")
                message(WARNING "Output for target `${target}` doesn't exist: ${output}.")
                continue()
            endif()

            if(target_type STREQUAL "executable")
                file(INSTALL "${output}" DESTINATION "${arg_INSTALL_DIR}/tools")
            elseif(output MATCHES "(\\.dll|\\.pdb)$")
                file(INSTALL "${output}" DESTINATION "${arg_INSTALL_DIR}/bin")
            else()
                file(INSTALL "${output}" DESTINATION "${arg_INSTALL_DIR}/lib")
            endif()
        endforeach()
    endforeach()
endfunction()

function(vcpkg_gn_install)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH" "TARGETS")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_gn_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()

    vcpkg_build_ninja(TARGETS ${arg_TARGETS})

    vcpkg_find_acquire_program(GN)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_gn_install_install(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}/debug"
            TARGETS ${arg_TARGETS}
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_gn_install_install(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}"
            TARGETS ${arg_TARGETS}
        )
    endif()
endfunction()
