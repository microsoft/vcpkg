set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

vcpkg_find_acquire_program(PERL)
set(ENV{PERL} "${PERL}")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 00ea73f2546ddbc191e30be4db897fffb5c9da1be03781c3b3b00514c621ec0d10cee7bbfc2a53a0d79ded62e372d6b7ad93289e5f44475ddfc43816b1a31651
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
