set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

vcpkg_find_acquire_program(PERL)
set(ENV{PERL} "${PERL}")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 05b0288ca1f1371674516df2e6cc9034f34057bb86a4b1702577dcf1eb7ce4730fad3e660d69123f108aec1f1ab8a0f84aec50ada012fe523e94d10e2303835e
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
