set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

vcpkg_find_acquire_program(PERL)
set(ENV{PERL} "${PERL}")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 3ed21737facf48cac24a667dbaed84aa4d41e2bb0c532abba7c60c5bb5d78a416dcd402ed0ebbe1a8c46b54787fb35782a3ec35f69a96fffd2d01ee87987fa92
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS "--disable-werror"
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSING" "${SOURCE_PATH}/COPYING.LIB")
