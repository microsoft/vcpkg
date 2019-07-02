## # vcpkg_pkgconfig
##
## Create pkgconfig files. Function does nothing on windows.
##
## ## Usage
## ```cmake
## vcpkg_pkgconfig(
##     [NAME <${PORT}>]
##     [REMOVE]
##     [COMMON <-l${PORT}>...]
##     [RELEASE ...]
##     [DEBUG ...]
##     [DEPENDS ...]
##     [DEPENDS_RELEASE ...]
##     [DEPENDS_DEBUG ...]
## )
## ```
##
## ## Parameters
## ### NAME
## Specifies the name of pc file. By default `${PORT}` is used as name.
##
## ### REMOVE
## Remove pkgconfig directory before creating pc files.
##
## ### COMMON
## Common libraries for `Libs:` section
##
## ### RELEASE
## Additional Release libraries. These are in addition to `COMMON`.
##
## ### DEBUG
## Additional Debug libraries. These are in addition to `COMMON`.
##
## ### REQUIRES
## Common dependencies for `Requires:` section
##
## ### REQUIRES_RELEASE
## Additional Release dependencies. These are in addition to `REQUIRES`.
##
## ### REQUIRES_DEBUG
## Additional Debug dependencies. These are in addition to `REQUIRES`.
##
## ## Notes
## If libraries are not specified `-l${PORT}` used.
## If dependencies are not specified, port dependencies are used.
##
function(vcpkg_pkgconfig)
    if(CMAKE_HOST_WIN32)
        return()
    endif()
    cmake_parse_arguments(_pc "REMOVE" "NAME" "COMMON;RELEASE;DEBUG;REQUIRES;REQUIRES_RELEASE;REQUIRES_DEBUG" ${ARGN})
    set(PORT_LIBS_RELEASE ${_pc_COMMON} ${_pc_RELEASE})
    set(PORT_LIBS_DEBUG ${_pc_COMMON} ${_pc_DEBUG})
    if(NOT PORT_LIBS_RELEASE)
        set(PORT_LIBS_RELEASE "-l${PORT}")
    endif()
    if(NOT PORT_LIBS_DEBUG)
        set(PORT_LIBS_DEBUG "-l${PORT}")
    endif()
    set(PORT_REQUIRES_RELEASE ${_pc_REQUIRES} ${_pc_REQUIRES_RELEASE})
    set(PORT_REQUIRES_DEBUG ${_pc_REQUIRES} ${_pc_REQUIRES_DEBUG})
    if(NOT PORT_REQUIRES_RELEASE)
        set(PORT_REQUIRES_RELEASE ${PORT_DEPENDENCIES})
    endif()
    if(NOT PORT_REQUIRES_DEBUG)
        set(PORT_REQUIRES_DEBUG ${PORT_DEPENDENCIES})
    endif()
    if(NOT _pc_NAME)
        set(_pc_NAME ${PORT})
    endif()
    list(JOIN PORT_LIBS_RELEASE " " PORT_LIBS_RELEASE)
    list(JOIN PORT_LIBS_DEBUG " " PORT_LIBS_DEBUG)
    list(JOIN PORT_REQUIRES_RELEASE ", " PORT_REQUIRES_RELEASE)
    list(JOIN PORT_REQUIRES_DEBUG ", " PORT_REQUIRES_DEBUG)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if(_pc_REMOVE)
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
        endif()
        configure_file("${VCPKG_ROOT_DIR}/scripts/templates/release.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${_pc_NAME}.pc" @ONLY)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(_pc_REMOVE)
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
        endif()
        configure_file("${VCPKG_ROOT_DIR}/scripts/templates/debug.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${_pc_NAME}.pc" @ONLY)
    endif()
endfunction()
