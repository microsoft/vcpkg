vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-${VERSION}/mpfr-${VERSION}.tar.xz" "https://ftp.gnu.org/gnu/mpfr/mpfr-${VERSION}.tar.xz"
    FILENAME "mpfr-${VERSION}.tar.xz"
    SHA512 be468749bd88870dec37be35e544983a8fb7bda638eb9414c37334b9d553099ea2aa067045f51ae2c8ab86d852ef833e18161d173e414af0928e9a438c9b91f1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dll.patch
        src-only.patch
        4.1.1-p1.patch # https://www.mpfr.org/mpfr-4.1.1/#bugs
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
