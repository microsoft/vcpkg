function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(_vfp "" "PKG_CONFIG_PATH" "" ${ARGN})

    if(_vfp_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig was passed extra arguments: ${_vfp_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT _vfp_PKG_CONFIG_PATH)
        set(_vfp_PKG_CONFIG_PATH lib/pkgconfig/)
    endif()

    set(DEBUG_PKG_CONFIG_PATH ${CURRENT_PACKAGES_DIR}/debug/${_vfp_PKG_CONFIG_PATH})
    set(RELEASE_PKG_CONFIG_PATH ${CURRENT_PACKAGES_DIR}/${_vfp_PKG_CONFIG_PATH})

    file(GLOB DEBUG_PC_FILES LIST_DIRECTORIES false ${DEBUG_PKG_CONFIG_PATH}/*.pc)
    file(GLOB RELEASE_PC_FILES LIST_DIRECTORIES false ${RELEASE_PKG_CONFIG_PATH}/*.pc)

    foreach(DEBUG_PC_FILE ${DEBUG_PC_FILES})
        file(READ ${DEBUG_PC_FILE} DEBUG_PC)
        string(REGEX REPLACE \(^|\n\)prefix=[^\n]+ \\1prefix=\"${CURRENT_INSTALLED_DIR}/debug\" DEBUG_PC_FIXED "${DEBUG_PC}")
        string(REGEX REPLACE \(^|\n\)includedir=[^\n]+ \\1includedir=\"\$\{prefix\}/../include\" DEBUG_PC_FIXED "${DEBUG_PC_FIXED}")
        file(WRITE ${DEBUG_PC_FILE} "${DEBUG_PC_FIXED}")
    endforeach()

    foreach(RELEASE_PC_FILE ${RELEASE_PC_FILES})
        file(READ ${RELEASE_PC_FILE} RELEASE_PC)
        string(REGEX REPLACE \(^|\n\)prefix=[^\n]+ \\1prefix=\"${CURRENT_INSTALLED_DIR}\" RELEASE_PC_FIXED "${RELEASE_PC}")
        file(WRITE ${RELEASE_PC_FILE} "${RELEASE_PC_FIXED}")
    endforeach()

endfunction()
