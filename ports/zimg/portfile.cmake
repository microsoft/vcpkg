vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sekrit-twc/zimg
    REF release-${VERSION}
    SHA512 98d7d65085530e0e1d3e25218608867f1e8d978fc759777efe2e6034baa31db10f1dda46ef8e00ec6f3c23b91aea839da076bfa4fcb75d98111a08513f45506d
    HEAD_REF master
    PATCHES
        fix-unsupported-compiler-flag.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
