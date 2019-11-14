## # vcpkg_sync_gn
##
## Fetch google project
##
## ## Usage:
## ```cmake
## vcpkg_sync_gn(...)
## ```
##
## ## Parameters:
## See [`vcpkg_sync_gn()`](vcpkg_sync_gn.md).
##
## ## Notes:
## This command transparently forwards to [`vcpkg_sync_gn()`](vcpkg_sync_gn.md)
##
## ## Examples
##

function(vcpkg_sync_gn)
    cmake_parse_arguments(_csg
        "ALWAYS_FETCH"
        "SOURCE_PATH;VER"
        ""
        ${ARGN}
    )
    
    vcpkg_find_acquire_program(GN)
    get_filename_component(GN_PATH ${GN} DIRECTORY)
    set(GC ${GN_PATH}/../../../gclient)
    
    # configure gclient in source
    if (NOT EXISTS ${_csg_SOURCE_PATH}/${_csg_PROJECT_SUBPATH}/.gclient)
        file(COPY ${GN_PATH}/.gclient DESTINATION ${SOURCE_PATH})
    endif()
    
    if (${_csg_ALWAYS_FETCH} OR (NOT EXISTS ${_csg_SOURCE_PATH}/${_csg_VER}_sync_done))
        message(STATUS "Fetching ${PORT}...\nThis may take several hours.")
        vcpkg_execute_required_process(
            COMMAND cmd /c ${GC} sync
            WORKING_DIRECTORY ${_csg_SOURCE_PATH}
            LOGNAME sync-${TARGET_TRIPLET}
        )
        file(WRITE ${_csg_SOURCE_PATH}/${_csg_VER}_sync_done "")
    endif()
    
endfunction()
