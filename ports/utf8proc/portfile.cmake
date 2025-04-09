vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF a1b99daa2a3393884220264c927a48ba1251a9c6 # v2.10.0
    SHA512 ed32eadb4c051410c1aff57f490459436d30bc943800d953bbb8d52178ab1ab0cf54b10982dab77eccce6d1354b1831b9528627137367ca7eeef813e4fd5ef73
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
