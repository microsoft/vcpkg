#[===[.md:
# vcpkg_install_gn

Installs a GN project

## Usage:
```cmake
vcpkg_install_gn(
     SOURCE_PATH <SOURCE_PATH>
     [TARGETS <target>...]
)
```

## Parameters:
### SOURCE_PATH
The path to the source directory

### TARGETS
Only install the specified targets.

Note: includes must be handled separately
#]===]

if(DEFINED Z_VCPKG_GN_INSTALL_GUARD)
    return()
endif()
set(Z_VCPKG_GN_INSTALL_GUARD ON)

function(z_vcpkg_gn_install_get_target_type out)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "SOURCE_PATH;BUILD_DIR;TARGET" "")
    execute_process(
        COMMAND "${GN}" desc "${arg_BUILD_DIR}" "${arg_TARGET}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX MATCH "type: ([A-Za-z0-9_]+)" output "${output}")
    set("${out}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_gn_install_get_desc out)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "SOURCE_PATH;BUILD_DIR;TARGET;DISPLAY" "")
    execute_process(
        COMMAND ${GN} desc "${arg_BUILD_DIR}" "${arg_TARGET}" "${arg_DISPLAY}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE "\n|(\r\n)" ";" output "${output}")
    set("${out}" "${output}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_gn_install_actual_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH;BUILD_DIR;INSTALL_DIR" "TARGETS")
    foreach(target IN LISTS arg_TARGETS)
        # GN targets must start with a //
        z_vcpkg_install_get_desc(outputs
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${arg_BUILD_DIR}"
            TARGET "//${target}"
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
                message(WARNING "Output for target \"${target}\" doesn't exist: \"${output}\".")
                continue()
            endif()

            if(target_type STREQUAL "executable")
                file(INSTALL "${output}" DESTINATION "${INSTALL_DIR}/tools")
            elseif("${output}" MATCHES "(\\.dll|\\.pdb)$")
                file(INSTALL "${output}" DESTINATION "${INSTALL_DIR}/bin")
            else()
                file(INSTALL "${output}" DESTINATION "${INSTALL_DIR}/lib")
            endif()
        endforeach()
    endforeach()
endfunction()

function(vcpkg_gn_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH" "TARGETS")

    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()
    if(NOT DEFINED arg_TARGETS)
        message(FATAL_ERROR "TARGETS must be specified.")
    endif()

    vcpkg_build_ninja(TARGETS ${arg_TARGETS})

    vcpkg_find_acquire_program(GN)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_gn_install_actual_install(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}/debug"
            TARGETS ${arg_TARGETS}
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_gn_install_actual_install(
            SOURCE_PATH "${arg_SOURCE_PATH}"
            BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}"
            TARGETS ${arg_TARGETS}
        )
    endif()
endfunction()
