cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)

get_filename_component(_vcpkg_wx_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(wxWidgets_USE_FILE "${_vcpkg_wx_root}/share/wxwidgets/wxWidgetsConfig.cmake")

if(WIN32 AND CMAKE_HOST_WIN32 AND "@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
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
