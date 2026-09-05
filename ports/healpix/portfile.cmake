vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO healpix
    REF Healpix_${VERSION}
    FILENAME "healpix_cxx-${VERSION}.0.tar.gz"
    SHA512 0e797773e3831fad155e5b670e5cbd9c58a40dba2883b45b757ac2f520fc56591309d93cbcb90a23ff68b6207a0081dcbc781b5e91efd60614104a3ee87ef55e
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
