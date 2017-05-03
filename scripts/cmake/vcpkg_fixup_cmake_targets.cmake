#.rst:
# .. command:: vcpkg_fixup_cmake_targets
#
#  Transform all /debug/share/<port>/*targets-debug.cmake files and move them to /share/<port>.
#  Removes all /debug/share/<port>/*targets.cmake and /debug/share/<port>/*config.cmake
#
#  ::
#  vcpkg_fixup_cmake_targets()
#

function(vcpkg_fixup_cmake_targets)
    cmake_parse_arguments(_vfct "" "" "" ${ARGN})

    set(DEBUG_SHARE ${CURRENT_PACKAGES_DIR}/debug/share/${PORT})
    set(RELEASE_SHARE ${CURRENT_PACKAGES_DIR}/share/${PORT})

    if(NOT EXISTS ${DEBUG_SHARE})
        message(FATAL_ERROR "'${DEBUG_SHARE}' does not exist")
    endif()

    file(GLOB UNUSED_FILES "${DEBUG_SHARE}/*[Tt]argets.cmake" "${DEBUG_SHARE}/*[Cc]onfig.cmake")
    file(REMOVE ${UNUSED_FILES})

    file(GLOB DEBUG_TARGETS "${DEBUG_SHARE}/*[Tt]argets-debug.cmake")

    foreach(DEBUG_TARGET ${DEBUG_TARGETS})
        get_filename_component(DEBUG_TARGET_NAME ${DEBUG_TARGET} NAME)

        file(READ ${DEBUG_TARGET} _contents)
        string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" _contents "${_contents}")
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
