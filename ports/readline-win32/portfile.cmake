vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaozhuai/readline-win32
    REF 8f141e9a77f81fae5b67f915621988aef116e9ae
    SHA512 2eb88a2fa3780df1bb8fa5dfc0be197113d3789cd7b494c0c30509099a6c4818cf14d8301d312747107b2b4f8e52e5a2ed93d3fe5fbbd6b796f780e2f1e0f729
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-readline-win32)
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/readline/rlstdc.h"
        "defined(USE_READLINE_STATIC)" "1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
