cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)

get_filename_component(_vcpkg_wx_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(wxWidgets_ROOT_DIR "${_vcpkg_wx_root}" CACHE INTERNAL "")
set(WX_ROOT_DIR "${_vcpkg_wx_root}" CACHE INTERNAL "")
unset(_vcpkg_wx_root)

if(WIN32 AND CMAKE_HOST_WIN32)
    # Find all libs with "32" infix which is unknown to FindwxWidgets.cmake
    function(z_vcpkg_wxwidgets_find_base_library BASENAME)
        find_library(WX_${BASENAME}d wx${BASENAME}32ud NAMES wx${BASENAME}d PATHS "${wxWidgets_ROOT_DIR}/debug/lib" NO_DEFAULT_PATH)
        find_library(WX_${BASENAME}  wx${BASENAME}32u  NAMES wx${BASENAME}  PATHS "${wxWidgets_ROOT_DIR}/lib" NO_DEFAULT_PATH REQUIRED)
    endfunction()
    function(z_vcpkg_wxwidgets_find_suffix_library BASENAME)
        foreach(lib IN LISTS ARGN)
            find_library(WX_${lib}d NAMES wx${BASENAME}32ud_${lib} PATHS "${wxWidgets_ROOT_DIR}/debug/lib" NO_DEFAULT_PATH)
            find_library(WX_${lib}  NAMES wx${BASENAME}32u_${lib}  PATHS "${wxWidgets_ROOT_DIR}/lib" NO_DEFAULT_PATH)
        endforeach()
    endfunction()
    z_vcpkg_wxwidgets_find_base_library(base)
    z_vcpkg_wxwidgets_find_suffix_library(base net odbc xml)
    z_vcpkg_wxwidgets_find_suffix_library(msw core adv aui html media xrc dbgrid gl qa richtext stc ribbon propgrid webview)
    if(WX_stc AND "@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        z_vcpkg_wxwidgets_find_base_library(scintilla)
    endif()
    # Force FindwxWidgets.cmake win32 mode for all windows targets built on windows
    set(_vcpkg_wxwidgets_backup_crosscompiling "${CMAKE_CROSSCOMPILING}")
    set(CMAKE_CROSSCOMPILING 0)
    set(wxWidgets_LIB_DIR "${wxWidgets_ROOT_DIR}/lib" CACHE INTERNAL "")
else()
    # FindwxWidgets.cmake unix mode, single-config
    if(MINGW)
        # Force FindwxWidgets.cmake unix mode for mingw cross builds
        set(_vcpkg_wxwidgets_backup_crosscompiling "${CMAKE_CROSSCOMPILING}")
        set(CMAKE_CROSSCOMPILING 1)
    endif()
    set(_vcpkg_wxconfig "")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR "Debug" IN_LIST MAP_IMPORTED_CONFIG_${CMAKE_BUILD_TYPE})
        # Debug
        set(wxWidgets_LIB_DIR "${wxWidgets_ROOT_DIR}/debug/lib" CACHE INTERNAL "")
        file(GLOB _vcpkg_wxconfig LIST_DIRECTORIES false "${wxWidgets_LIB_DIR}/wx/config/*")
    endif()
    if(NOT _vcpkg_wxconfig)
        # Release or fallback
        set(wxWidgets_LIB_DIR "${wxWidgets_ROOT_DIR}/lib" CACHE INTERNAL "")
        file(GLOB _vcpkg_wxconfig LIST_DIRECTORIES false "${wxWidgets_LIB_DIR}/wx/config/*")
    endif()
    set(wxWidgets_CONFIG_EXECUTABLE "${_vcpkg_wxconfig}" CACHE INTERNAL "")
    unset(_vcpkg_wxconfig)
endif()
set(WX_LIB_DIR "${wxWidgets_LIB_DIR}" CACHE INTERNAL "")

_find_package(${ARGS})

if(DEFINED _vcpkg_wxwidgets_backup_crosscompiling)
    set(CMAKE_CROSSCOMPILING "${_vcpkg_wxwidgets_backup_crosscompiling}")
    unset(_vcpkg_wxwidgets_backup_crosscompiling)
endif()

if(WIN32 AND CMAKE_HOST_WIN32 AND "@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static" AND NOT "wx::core" IN_LIST wxWidgets_LIBRARIES)
    find_package(EXPAT QUIET)
    find_package(JPEG QUIET)
    find_package(PNG QUIET)
    find_package(TIFF QUIET)
    find_package(ZLIB QUIET)
    list(APPEND wxWidgets_LIBRARIES
        ${EXPAT_LIBRARIES}
        ${JPEG_LIBRARIES}
        ${PNG_LIBRARIES}
        ${TIFF_LIBRARIES}
        ${ZLIB_LIBRARIES}
    )
endif()

cmake_policy(POP)
