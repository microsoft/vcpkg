set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

vcpkg_find_acquire_program(PERL)
set(ENV{PERL} "${PERL}")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 e66f78adda1989e635d8df3f0273816c979d9bcb0396ed8bfa326541e7e8e0d092d63d19dba3dd5aafb887f74eff835d344d4cffc0a98d7e8ee8b2de3b88fabc
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
