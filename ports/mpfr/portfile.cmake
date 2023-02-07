vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-${VERSION}/mpfr-${VERSION}.tar.xz" "https://ftp.gnu.org/gnu/mpfr/mpfr-${VERSION}.tar.xz"
    FILENAME "mpfr-${VERSION}.tar.xz"
    SHA512 58e843125884ca58837ae5159cd4092af09e8f21931a2efd19c15de057c9d1dc0753ae95c592e2ce59a727fbc491af776db8b00a055320413cdcf2033b90505c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dll.patch
        src-only.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/AUTHORS"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/BUGS"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING.LESSER"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/NEWS"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/TODO"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING.LESSER")
