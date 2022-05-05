cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)

get_filename_component(_vcpkg_wx_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(wxWidgets_ROOT_DIR "${_vcpkg_wx_root}" CACHE INTERNAL "")
set(WX_ROOT_DIR "${_vcpkg_wx_root}" CACHE INTERNAL "")
unset(_vcpkg_wx_root)

if(MINGW)
    # Force FindwxWidgets.cmake unix mode, matching mingw install layout
    set(_vcpkg_wxwidgets_backup_crosscompiling "${CMAKE_CROSSCOMPILING}")
    set(CMAKE_CROSSCOMPILING 1)
elseif(WIN32)
    # Force FindwxWidgets.cmake win32 mode, matching win32 install layout
    set(_vcpkg_wxwidgets_backup_crosscompiling "${CMAKE_CROSSCOMPILING}")
    set(CMAKE_CROSSCOMPILING 0)
endif()

if(WIN32 AND NOT CMAKE_CROSSCOMPILING)
    # FindwxWidgets.cmake win32 mode, multi-config
    # Get cache variables for debug libs
    set(wxWidgets_LIB_DIR "${wxWidgets_ROOT_DIR}/debug/lib" CACHE INTERNAL "")
    set(WX_LIB_DIR "${wxWidgets_LIB_DIR}" CACHE INTERNAL "")
    _find_package(${ARGS})
    # Reset for regular lookup
    unset(wxWidgets_CONFIGURATION CACHE)
    unset(wxWidgets_USE_REL_AND_DBG CACHE)
    set(WX_CONFIGURATION_LIST "")
    set(wxWidgets_LIB_DIR "${wxWidgets_ROOT_DIR}/lib" CACHE INTERNAL "")
else()
    # FindwxWidgets.cmake unix mode, single-config
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

if(WIN32 AND NOT MINGW AND "@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
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
