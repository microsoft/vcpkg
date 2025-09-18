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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/utf8proc)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(READ "${CURRENT_PACKAGES_DIR}/include/utf8proc.h" UTF8PROC_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "defined UTF8PROC_SHARED" "0" UTF8PROC_H "${UTF8PROC_H}")
else()
    string(REPLACE "defined UTF8PROC_SHARED" "1" UTF8PROC_H "${UTF8PROC_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/utf8proc.h" "${UTF8PROC_H}")

vcpkg_fixup_pkgconfig()

# Legacy
file(INSTALL "${CURRENT_PORT_DIR}/unofficial-utf8proc-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-utf8proc")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
