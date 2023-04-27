vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 0d2de880f7cff7ecd51c5cf5a22515ee13a4c006baf85493024ab667883caa4a5fad4d18395d2d901aade396c5d3e57b0f0337ed9680cf0edd620a223100a8b4
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSING" "${SOURCE_PATH}/COPYING.LIB")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
