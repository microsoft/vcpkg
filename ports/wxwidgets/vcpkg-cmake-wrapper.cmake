cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)

get_filename_component(_vcpkg_wx_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(wxWidgets_ROOT_DIR "${_vcpkg_wx_root}" CACHE INTERNAL "")
set(wxWidgets_INCLUDE_DIRS "${wxWidgets_ROOT_DIR}/include" CACHE INTERNAL "")
unset(_vcpkg_wx_root)

set(wxWidgets_USE_FILE "${wxWidgets_ROOT_DIR}/share/wxwidgets/wxWidgetsConfig.cmake")
set(wxWidgets_FOUND TRUE)
include(${wxWidgets_USE_FILE})

if(WIN32)
    set(wxWidgets_wxrc_EXECUTABLE "${wxWidgets_ROOT_DIR}/tools/wxwidgets/wxrc.exe" CACHE FILEPATH "Location of wxWidgets resource file compiler binary (wxrc)")
else()
    set(wxWidgets_CONFIG_EXECUTABLE "${wxWidgets_ROOT_DIR}/tools/wxwidgets/wx-config" CACHE FILEPATH "Location of wxWidgets library configuration provider binary (wx-config).")
endif()

foreach(libname ${wxWidgets_COMPONENTS})
    get_target_property(config wx::${libname} IMPORTED_IMPLIB)
    if(config)
        set(WX_${libname} "${config}" CACHE FILEPATH "${libname}")
    else()
        get_target_property(config wx::${libname} IMPORTED_IMPLIB_RELEASE)
        set(WX_${libname} "${config}" CACHE FILEPATH "${libname}")
        get_target_property(config wx::${libname} IMPORTED_IMPLIB_DEBUG)
        if(NOT "${config}" STREQUAL "")
            set(WX_${libname}d "${config}" CACHE FILEPATH "${libname}d")
        endif()
    endif()
endforeach()

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    if(WIN32 AND CMAKE_HOST_WIN32)
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
    else()
        find_package(OpenSSL QUIET)
        find_package(OpenGL QUIET)
        find_package(ZLIB QUIET)
        find_package(unofficial-nanosvg QUIET)
    endif()
endif()

cmake_policy(POP)
