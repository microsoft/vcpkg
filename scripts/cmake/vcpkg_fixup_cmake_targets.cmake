# DEPRECATED BY ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup
#[===[.md:
# vcpkg_fixup_cmake_targets

Merge release and debug CMake targets and configs to support multiconfig generators.

Additionally corrects common issues with targets, such as absolute paths and incorrectly placed binaries.

## Usage
```cmake
vcpkg_fixup_cmake_targets([CONFIG_PATH <share/${PORT}>] 
                          [TARGET_PATH <share/${PORT}>] 
                          [TOOLS_PATH <tools/${PORT}>]
                          [DO_NOT_DELETE_PARENT_CONFIG_PATH])
```

## Parameters

### CONFIG_PATH
Subpath currently containing `*.cmake` files subdirectory (like `lib/cmake/${PORT}`). Should be relative to `${CURRENT_PACKAGES_DIR}`.

Defaults to `share/${PORT}`.

### TARGET_PATH
Subpath to which the above `*.cmake` files should be moved. Should be relative to `${CURRENT_PACKAGES_DIR}`.
This needs to be specified if the port name differs from the `find_package()` name.

Defaults to `share/${PORT}`.

### DO_NOT_DELETE_PARENT_CONFIG_PATH
By default the parent directory of CONFIG_PATH is removed if it is named "cmake".
Passing this option disable such behavior, as it is convenient for ports that install
more than one CMake package configuration file.

### NO_PREFIX_CORRECTION
Disables the correction of_IMPORT_PREFIX done by vcpkg due to moving the targets.
Currently the correction does not take into account how the files are moved and applies
I rather simply correction which in some cases will yield the wrong results.

### TOOLS_PATH
Define the base path to tools. Default: `tools/<PORT>`

## Notes
Transform all `/debug/<CONFIG_PATH>/*targets-debug.cmake` files and move them to `/<TARGET_PATH>`.
Removes all `/debug/<CONFIG_PATH>/*targets.cmake` and `/debug/<CONFIG_PATH>/*config.cmake`.

Transform all references matching `/bin/*.exe` to `/${TOOLS_PATH}/*.exe` on Windows.
Transform all references matching `/bin/*` to `/${TOOLS_PATH}/*`  on other platforms.

Fix `${_IMPORT_PREFIX}` in auto generated targets to be one folder deeper.
Replace `${CURRENT_INSTALLED_DIR}` with `${_IMPORT_PREFIX}` in configs and targets.

## Examples

* [concurrentqueue](https://github.com/Microsoft/vcpkg/blob/master/ports/concurrentqueue/portfile.cmake)
* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [nlohmann-json](https://github.com/Microsoft/vcpkg/blob/master/ports/nlohmann-json/portfile.cmake)
#]===]

function(vcpkg_fixup_cmake_targets)
    if(Z_VCPKG_CMAKE_CONFIG_FIXUP_GUARD)
        message(FATAL_ERROR "The ${PORT} port already depends on vcpkg-cmake-config; using both vcpkg-cmake-config and vcpkg_fixup_cmake_targets in the same port is unsupported.")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 arg "DO_NOT_DELETE_PARENT_CONFIG_PATH" "CONFIG_PATH;TARGET_PATH;NO_PREFIX_CORRECTION;TOOLS_PATH" "")

    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_cmake_targets was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT arg_TARGET_PATH)
        set(arg_TARGET_PATH share/${PORT})
    endif()
    
    if(NOT arg_TOOLS_PATH)
        set(arg_TOOLS_PATH tools/${PORT})
    endif()

    string(REPLACE "." "\\." EXECUTABLE_SUFFIX "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

    set(DEBUG_SHARE ${CURRENT_PACKAGES_DIR}/debug/${arg_TARGET_PATH})
    set(RELEASE_SHARE ${CURRENT_PACKAGES_DIR}/${arg_TARGET_PATH})

    if(arg_CONFIG_PATH AND NOT RELEASE_SHARE STREQUAL "${CURRENT_PACKAGES_DIR}/${arg_CONFIG_PATH}")
        if(arg_CONFIG_PATH STREQUAL "share")
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/share2)
            file(RENAME ${CURRENT_PACKAGES_DIR}/share ${CURRENT_PACKAGES_DIR}/share2)
            set(arg_CONFIG_PATH share2)
        endif()

        set(DEBUG_CONFIG ${CURRENT_PACKAGES_DIR}/debug/${arg_CONFIG_PATH})
        set(RELEASE_CONFIG ${CURRENT_PACKAGES_DIR}/${arg_CONFIG_PATH})
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            if(NOT EXISTS ${DEBUG_CONFIG})
                message(FATAL_ERROR "'${DEBUG_CONFIG}' does not exist.")
            endif()

            # This roundabout handling enables CONFIG_PATH share
            file(MAKE_DIRECTORY ${DEBUG_SHARE})
            file(GLOB FILES ${DEBUG_CONFIG}/*)
            file(COPY ${FILES} DESTINATION ${DEBUG_SHARE})
            file(REMOVE_RECURSE ${DEBUG_CONFIG})
        endif()

        file(GLOB FILES ${RELEASE_CONFIG}/*)
        file(COPY ${FILES} DESTINATION ${RELEASE_SHARE})
        file(REMOVE_RECURSE ${RELEASE_CONFIG})

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG} NAME)
            string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
            if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE ${DEBUG_CONFIG})
            else()
                get_filename_component(DEBUG_CONFIG_PARENT_DIR ${DEBUG_CONFIG} DIRECTORY)
                get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG_PARENT_DIR} NAME)
                string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
                if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                    file(REMOVE_RECURSE ${DEBUG_CONFIG_PARENT_DIR})
                endif()
            endif()
        endif()

        get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG} NAME)
        string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
        if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
            file(REMOVE_RECURSE ${RELEASE_CONFIG})
        else()
            get_filename_component(RELEASE_CONFIG_PARENT_DIR ${RELEASE_CONFIG} DIRECTORY)
            get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG_PARENT_DIR} NAME)
            string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
            if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE ${RELEASE_CONFIG_PARENT_DIR})
            endif()
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(NOT EXISTS "${DEBUG_SHARE}")
            message(FATAL_ERROR "'${DEBUG_SHARE}' does not exist.")
        endif()
    endif()

    file(GLOB_RECURSE UNUSED_FILES
        "${DEBUG_SHARE}/*[Tt]argets.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig.cmake"
        "${DEBUG_SHARE}/*[Cc]onfigVersion.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig-version.cmake"
    )
    if(UNUSED_FILES)
        file(REMOVE ${UNUSED_FILES})
    endif()

    file(GLOB_RECURSE RELEASE_TARGETS
        "${RELEASE_SHARE}/*-release.cmake"
    )
    foreach(RELEASE_TARGET IN LISTS RELEASE_TARGETS)
        file(READ ${RELEASE_TARGET} _contents)
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" _contents "${_contents}")
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/${arg_TOOLS_PATH}/\\1" _contents "${_contents}")
        file(WRITE ${RELEASE_TARGET} "${_contents}")
    endforeach()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB_RECURSE DEBUG_TARGETS
            "${DEBUG_SHARE}/*-debug.cmake"
            )
        foreach(DEBUG_TARGET IN LISTS DEBUG_TARGETS)
            file(RELATIVE_PATH DEBUG_TARGET_REL "${DEBUG_SHARE}" "${DEBUG_TARGET}")

            file(READ ${DEBUG_TARGET} _contents)
            string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" _contents "${_contents}")
            string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \";]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/${arg_TOOLS_PATH}/\\1" _contents "${_contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/lib" "\${_IMPORT_PREFIX}/debug/lib" _contents "${_contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/debug/bin" _contents "${_contents}")
            file(WRITE ${RELEASE_SHARE}/${DEBUG_TARGET_REL} "${_contents}")

            file(REMOVE ${DEBUG_TARGET})
        endforeach()
    endif()

    #Fix ${_IMPORT_PREFIX} in cmake generated targets and configs;
    #Since those can be renamed we have to check in every *.cmake
    file(GLOB_RECURSE MAIN_CMAKES "${RELEASE_SHARE}/*.cmake")

    foreach(MAIN_CMAKE IN LISTS MAIN_CMAKES)
        file(READ ${MAIN_CMAKE} _contents)
        #This correction is not correct for all cases. To make it correct for all cases it needs to consider
        #original folder deepness to CURRENT_PACKAGES_DIR in comparison to the moved to folder deepness which
        #is always at least (>=) 2, e.g. share/${PORT}. Currently the code assumes it is always 2 although
        #this requirement is only true for the *Config.cmake. The targets are not required to be in the same
        #folder as the *Config.cmake!
        if(NOT arg_NO_PREFIX_CORRECTION)
            string(REGEX REPLACE
                "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
                "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
                _contents "${_contents}") # see #1044 for details why this replacement is necessary. See #4782 why it must be a regex.
            string(REGEX REPLACE
                "get_filename_component\\(PACKAGE_PREFIX_DIR \"\\\${CMAKE_CURRENT_LIST_DIR}/\\.\\./(\\.\\./)*\" ABSOLUTE\\)"
                "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)"
                _contents "${_contents}")
            string(REGEX REPLACE
                "get_filename_component\\(PACKAGE_PREFIX_DIR \"\\\${CMAKE_CURRENT_LIST_DIR}/\\.\\.((\\\\|/)\\.\\.)*\" ABSOLUTE\\)"
                "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)"
                _contents "${_contents}") # This is a meson-related workaround, see https://github.com/mesonbuild/meson/issues/6955
        endif()

        #Fix wrongly absolute paths to install dir with the correct dir using ${_IMPORT_PREFIX}
        #This happens if vcpkg built libraries are directly linked to a target instead of using
        #an imported target for it. We could add more logic here to identify defect target files.
        #Since the replacement here in a multi config build always requires a generator expression
        #in front of the absoulte path to ${CURRENT_INSTALLED_DIR}. So the match should always be at
        #least >:${CURRENT_INSTALLED_DIR}.
        #In general the following generator expressions should be there:
        #\$<\$<CONFIG:DEBUG>:${CURRENT_INSTALLED_DIR}/debug/lib/somelib>
        #and/or
        #\$<\$<NOT:\$<CONFIG:DEBUG>>:${CURRENT_INSTALLED_DIR}/lib/somelib>
        #with ${CURRENT_INSTALLED_DIR} being fully expanded
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${_IMPORT_PREFIX}]] _contents "${_contents}")
        file(WRITE ${MAIN_CMAKE} "${_contents}")
    endforeach()

    if (VCPKG_TARGET_IS_OSX)
        # see #16259 for details why this replacement is necessary.
        file(GLOB targets_files "${RELEASE_SHARE}/*[Tt]argets.cmake")
        if (targets_files STREQUAL "")
            file(GLOB targets_files "${RELEASE_SHARE}/*[Cc]onfig.cmake")
        endif()
        foreach(targets_file IN LISTS targets_files)
            file(READ "${targets_file}" targets_content)
            string(REGEX MATCHALL "INTERFACE_LINK_LIBRARIES[^\n]*\n" library_contents "${targets_content}")
            foreach(line IN LISTS library_contents)
                set(fixed_line "${line}")
                string(REGEX MATCHALL [[/[^ ;"]+/[^ ;"/]+\.framework]] frameworks "${line}")
                foreach(framework IN LISTS frameworks)
                    if(NOT framework MATCHES [[^(.+)/(.+)\.framework$]])
                        continue()
                    endif()
                    set(path "${CMAKE_MATCH_1}")
                    set(name "${CMAKE_MATCH_2}")
                    if(NOT DEFINED VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
                        set(_saved_buildtrees_dir "${CURRENT_BUILDTREES_DIR}")
                        set(CURRENT_BUILDTREES_DIR "${CURRENT_BUILDTREES_DIR}/get-cmake-vars")
                        z_vcpkg_get_cmake_vars(cmake_vars_file)
                        debug_message("Including cmake vars from: ${cmake_vars_file}")
                        include("${cmake_vars_file}")
                        set(VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "${VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES}" PARENT_SCOPE)
                        set(CURRENT_BUILDTREES_DIR "${_saved_buildtrees_dir}")
                    endif()
                    list(FIND VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "${path}" index)
                    if(NOT index EQUAL -1)
                        string(REPLACE "${framework}" "-framework ${name}" fixed_line "${fixed_line}")
                    endif()
                endforeach()
                string(REPLACE "${line}" "${fixed_line}" targets_content "${targets_content}")
            endforeach()
            file(WRITE "${targets_file}" "${targets_content}")
        endforeach()
    endif()

    # Remove /debug/<target_path>/ if it's empty.
    file(GLOB_RECURSE REMAINING_FILES "${DEBUG_SHARE}/*")
    if(NOT REMAINING_FILES)
        file(REMOVE_RECURSE ${DEBUG_SHARE})
    endif()

    # Remove /debug/share/ if it's empty.
    file(GLOB_RECURSE REMAINING_FILES "${CURRENT_PACKAGES_DIR}/debug/share/*")
    if(NOT REMAINING_FILES)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    endif()

    # Patch out any remaining absolute references
    file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" CMAKE_CURRENT_PACKAGES_DIR)
    file(GLOB CMAKE_FILES ${RELEASE_SHARE}/*.cmake)
    foreach(CMAKE_FILE IN LISTS CMAKE_FILES)
        file(READ ${CMAKE_FILE} _contents)
        string(REPLACE "${CMAKE_CURRENT_PACKAGES_DIR}" "\${CMAKE_CURRENT_LIST_DIR}/../.." _contents "${_contents}")
        file(WRITE ${CMAKE_FILE} "${_contents}")
    endforeach()
endfunction()
