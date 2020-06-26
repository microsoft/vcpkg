## # vcpkg_fixup_cmake_targets
##
## Merge release and debug CMake targets and configs to support multiconfig generators.
##
## Additionally corrects common issues with targets, such as absolute paths and incorrectly placed binaries.
##
## ## Usage
## ```cmake
## vcpkg_fixup_cmake_targets([CONFIG_PATH <share/${PORT}>] [TARGET_PATH <share/${PORT}>] [DO_NOT_DELETE_PARENT_CONFIG_PATH])
## ```
##
## ## Parameters
##
## ### CONFIG_PATH
## Subpath currently containing `*.cmake` files subdirectory (like `lib/cmake/${PORT}`). Should be relative to `${CURRENT_PACKAGES_DIR}`.
##
## Defaults to `share/${PORT}`.
##
## ### TARGET_PATH
## Subpath to which the above `*.cmake` files should be moved. Should be relative to `${CURRENT_PACKAGES_DIR}`.
## This needs to be specified if the port name differs from the `find_package()` name.
##
## Defaults to `share/${PORT}`.
##
## ### DO_NOT_DELETE_PARENT_CONFIG_PATH 
## By default the parent directory of CONFIG_PATH is removed if it is named "cmake".
## Passing this option disable such behavior, as it is convenient for ports that install
## more than one CMake package configuration file.
##
## ## Notes
## Transform all `/debug/<CONFIG_PATH>/*targets-debug.cmake` files and move them to `/<TARGET_PATH>`.
## Removes all `/debug/<CONFIG_PATH>/*targets.cmake` and `/debug/<CONFIG_PATH>/*config.cmake`.
##
## Transform all references matching `/bin/*.exe` to `/tools/<port>/*.exe` on Windows.
## Transform all references matching `/bin/*` to `/tools/<port>/*` on other platforms.
##
## Fix `${_IMPORT_PREFIX}` in auto generated targets to be one folder deeper.
## Replace `${CURRENT_INSTALLED_DIR}` with `${_IMPORT_PREFIX}` in configs and targets.
##
## ## Examples
##
## * [concurrentqueue](https://github.com/Microsoft/vcpkg/blob/master/ports/concurrentqueue/portfile.cmake)
## * [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
## * [nlohmann-json](https://github.com/Microsoft/vcpkg/blob/master/ports/nlohmann-json/portfile.cmake)
function(vcpkg_fixup_cmake_targets)
    cmake_parse_arguments(_vfct "DO_NOT_DELETE_PARENT_CONFIG_PATH" "CONFIG_PATH;TARGET_PATH" "" ${ARGN})

    if(_vfct_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_cmake_targets was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT _vfct_TARGET_PATH)
        set(_vfct_TARGET_PATH share/${PORT})
    endif()

    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(EXECUTABLE_SUFFIX "\\.exe")
    else()
        set(EXECUTABLE_SUFFIX)
    endif()

    set(DEBUG_SHARE ${CURRENT_PACKAGES_DIR}/debug/${_vfct_TARGET_PATH})
    set(RELEASE_SHARE ${CURRENT_PACKAGES_DIR}/${_vfct_TARGET_PATH})

    if(_vfct_CONFIG_PATH AND NOT RELEASE_SHARE STREQUAL "${CURRENT_PACKAGES_DIR}/${_vfct_CONFIG_PATH}")
        if(_vfct_CONFIG_PATH STREQUAL "share")
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/share2)
            file(RENAME ${CURRENT_PACKAGES_DIR}/share ${CURRENT_PACKAGES_DIR}/share2)
            set(_vfct_CONFIG_PATH share2)
        endif()

        set(DEBUG_CONFIG ${CURRENT_PACKAGES_DIR}/debug/${_vfct_CONFIG_PATH})
        set(RELEASE_CONFIG ${CURRENT_PACKAGES_DIR}/${_vfct_CONFIG_PATH})
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
            if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT _vfct_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE ${DEBUG_CONFIG})
            else()
                get_filename_component(DEBUG_CONFIG_PARENT_DIR ${DEBUG_CONFIG} DIRECTORY)
                get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG_PARENT_DIR} NAME)
                string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
                if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT _vfct_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                    file(REMOVE_RECURSE ${DEBUG_CONFIG_PARENT_DIR})
                endif()
            endif()
        endif()

        get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG} NAME)
        string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
        if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT _vfct_DO_NOT_DELETE_PARENT_CONFIG_PATH)
            file(REMOVE_RECURSE ${RELEASE_CONFIG})
        else()
            get_filename_component(RELEASE_CONFIG_PARENT_DIR ${RELEASE_CONFIG} DIRECTORY)
            get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG_PARENT_DIR} NAME)
            string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
            if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake" AND NOT _vfct_DO_NOT_DELETE_PARENT_CONFIG_PATH)
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
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/tools/${PORT}/\\1" _contents "${_contents}")
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
            string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \";]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/tools/${PORT}/\\1" _contents "${_contents}")
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
        string(REGEX REPLACE
            "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
            "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
            _contents "${_contents}") # see #1044 for details why this replacement is necessary. See #4782 why it must be a regex.
         string(REGEX REPLACE
            "get_filename_component\\(PACKAGE_PREFIX_DIR \"\\\${CMAKE_CURRENT_LIST_DIR}/\\.\\./(\\.\\./)*\" ABSOLUTE\\)"
            "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)"
            _contents "${_contents}")
        #Fix wrongly absolute paths to install dir with the correct dir using ${_IMPORT_PREFIX}
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${_IMPORT_PREFIX}]] _contents "${_contents}")
        file(WRITE ${MAIN_CMAKE} "${_contents}")
    endforeach()

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
