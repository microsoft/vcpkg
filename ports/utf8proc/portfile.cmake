vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF v${VERSION}
    SHA512 bf9bfb20036e8b709449ee4a11592becf99e61f4c82d03519ab9de1a93ca47d6f8ed4b0bb471f7ca3ae06293275a391a9102ae810a9e07e914789d05ddbd25ab
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUTF8PROC_ENABLE_TESTING=OFF
        -DUTF8PROC_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/utf8proc)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/utf8proc.h" "#ifdef UTF8PROC_STATIC" "#if 1 /* UTF8PROC_STATIC */")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/utf8proc_static.lib")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libutf8proc.pc" " -lutf8proc" " -lutf8proc_static")
        if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libutf8proc.pc" " -lutf8proc" " -lutf8proc_static")
        endif()
    endif()
endif()

# Legacy
file(INSTALL "${CURRENT_PORT_DIR}/unofficial-utf8proc-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-utf8proc")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
