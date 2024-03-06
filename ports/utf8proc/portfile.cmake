vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF 34db3f7954e9298e89f42641ac78e0450f80a70d # v2.9.0
    SHA512 41030ba99084d3941bb774d186712b9149e33606e8fda5be10dc83e3237df801998f46f0d49555f224e30609660e5e2d0ac9e9f22d76b95ed92daeaa3eacbd7e
    PATCHES
        export-cmake-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUTF8PROC_ENABLE_TESTING=OFF
        -DUTF8PROC_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-utf8proc CONFIG_PATH share/unofficial-utf8proc)

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

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
