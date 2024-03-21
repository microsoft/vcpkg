set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 61e5e393654f37775457474d4170098314879ee79963d423c1c461e80dc5dc74f0c161dd8754f016ce96109167be6c580ad23994fa1d2c38c54b96e602f3aece
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSING" "${SOURCE_PATH}/COPYING.LIB")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
