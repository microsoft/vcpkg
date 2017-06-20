#.rst:
# .. command:: vcpkg_fixup_cmake_targets
#
#  Transform all /debug/share/<port>/*targets-debug.cmake files and move them to /share/<port>.
#  Removes all /debug/share/<port>/*targets.cmake and /debug/share/<port>/*config.cmake
#
#  Transform all references matching /bin/*.exe to /tools/<port>/*.exe
#
#  ::
#  vcpkg_fixup_cmake_targets([CONFIG_PATH <config_path>])
#
#  ``CONFIG_PATH``
#    *.cmake files subdirectory (like "lib/cmake/${PORT}").
#

function(vcpkg_fixup_cmake_targets)
    cmake_parse_arguments(_vfct "" "CONFIG_PATH" "" ${ARGN})

    if(_vfct_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_cmake_targets was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    set(DEBUG_SHARE ${CURRENT_PACKAGES_DIR}/debug/share/${PORT})
    set(RELEASE_SHARE ${CURRENT_PACKAGES_DIR}/share/${PORT})

    if(_vfct_CONFIG_PATH)
        set(DEBUG_CONFIG ${CURRENT_PACKAGES_DIR}/debug/${_vfct_CONFIG_PATH})
        set(RELEASE_CONFIG ${CURRENT_PACKAGES_DIR}/${_vfct_CONFIG_PATH})

        if(NOT EXISTS ${DEBUG_CONFIG})
            message(FATAL_ERROR "'${DEBUG_CONFIG}' does not exist.")
        endif()

        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share)
        file(RENAME ${DEBUG_CONFIG} ${DEBUG_SHARE})
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
        file(RENAME ${RELEASE_CONFIG} ${RELEASE_SHARE})

        get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG} NAME)
        string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
        if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake")
            file(REMOVE_RECURSE ${DEBUG_CONFIG})
        else()
            get_filename_component(DEBUG_CONFIG_PARENT_DIR ${DEBUG_CONFIG} DIRECTORY)
            get_filename_component(DEBUG_CONFIG_DIR_NAME ${DEBUG_CONFIG_PARENT_DIR} NAME)
            string(TOLOWER "${DEBUG_CONFIG_DIR_NAME}" DEBUG_CONFIG_DIR_NAME)
            if(DEBUG_CONFIG_DIR_NAME STREQUAL "cmake")
                file(REMOVE_RECURSE ${DEBUG_CONFIG_PARENT_DIR})
            endif()
        endif()

        get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG} NAME)
        string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
        if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake")
            file(REMOVE_RECURSE ${RELEASE_CONFIG})
        else()
            get_filename_component(RELEASE_CONFIG_PARENT_DIR ${RELEASE_CONFIG} DIRECTORY)
            get_filename_component(RELEASE_CONFIG_DIR_NAME ${RELEASE_CONFIG_PARENT_DIR} NAME)
            string(TOLOWER "${RELEASE_CONFIG_DIR_NAME}" RELEASE_CONFIG_DIR_NAME)
            if(RELEASE_CONFIG_DIR_NAME STREQUAL "cmake")
                file(REMOVE_RECURSE ${RELEASE_CONFIG_PARENT_DIR})
            endif()
        endif()
    endif()

    if(NOT EXISTS ${DEBUG_SHARE})
        message(FATAL_ERROR "'${DEBUG_SHARE}' does not exist.")
    endif()

    file(GLOB UNUSED_FILES
        "${DEBUG_SHARE}/*[Tt]argets.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig.cmake"
        "${DEBUG_SHARE}/*[Cc]onfigVersion.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig-version.cmake"
    )
    file(REMOVE ${UNUSED_FILES})

    file(GLOB RELEASE_TARGETS
        "${RELEASE_SHARE}/*[Tt]argets-release.cmake"
        "${RELEASE_SHARE}/*[Cc]onfig-release.cmake"
    )
    foreach(RELEASE_TARGET ${RELEASE_TARGETS})
        get_filename_component(RELEASE_TARGET_NAME ${RELEASE_TARGET} NAME)

        file(READ ${RELEASE_TARGET} _contents)
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+\\.exe)" "\${_IMPORT_PREFIX}/tools/${PORT}/\\1" _contents "${_contents}")
        file(WRITE ${RELEASE_TARGET} "${_contents}")
    endforeach()

    file(GLOB DEBUG_TARGETS
        "${DEBUG_SHARE}/*[Tt]argets-debug.cmake"
        "${DEBUG_SHARE}/*[Cc]onfig-debug.cmake"
    )
    foreach(DEBUG_TARGET ${DEBUG_TARGETS})
        get_filename_component(DEBUG_TARGET_NAME ${DEBUG_TARGET} NAME)

        file(READ ${DEBUG_TARGET} _contents)
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+\\.exe)" "\${_IMPORT_PREFIX}/tools/${PORT}/\\1" _contents "${_contents}")
        string(REPLACE "\${_IMPORT_PREFIX}/lib" "\${_IMPORT_PREFIX}/debug/lib" _contents "${_contents}")
        string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/debug/bin" _contents "${_contents}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/${DEBUG_TARGET_NAME} "${_contents}")

        file(REMOVE ${DEBUG_TARGET})
    endforeach()

    # Remove /debug/share/<port>/ if it's empty.
    file(GLOB_RECURSE REMAINING_FILES "${DEBUG_SHARE}/*")
    if(NOT REMAINING_FILES)
        file(REMOVE_RECURSE ${DEBUG_SHARE})
    endif()

    # Remove /debug/share/ if it's empty.
    file(GLOB_RECURSE REMAINING_FILES "${CURRENT_PACKAGES_DIR}/debug/share/*")
    if(NOT REMAINING_FILES)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    endif()
endfunction()
