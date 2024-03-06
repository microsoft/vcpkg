vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "libunwind/libunwind"
    REF "v${VERSION}"
    HEAD_REF "v1.8-stable"
    SHA512 105bd4ff0f23f98046a4ed2cb58664083eba35154c92334a1f905ef13e1e92abbf87acb82556c9242c4209626f065d2519f3260e69d2146234a285b4ddd64470
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
