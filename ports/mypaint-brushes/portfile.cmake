set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mypaint/mypaint-brushes/releases/download/v${VERSION}/mypaint-brushes-${VERSION}.tar.xz"
    FILENAME "mypaint-brushes-${VERSION}.tar.xz"
    SHA512 22ff99c40a2fff71efd5c25a462cefb9948f0d258aee12e3eb924bac53733a2573e100454e2f3e4631d59eac013c2aaa7f32ff566843d23df971bf2aaa1181bd
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_make_install()

vcpkg_copy_pdbs()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/mypaint-brushes/pkgconfig/mypaint-brushes-1.0.pc" "${CURRENT_PACKAGES_DIR}/share/pkgconfig/mypaint-brushes-1.0.pc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/" "${CURRENT_PACKAGES_DIR}/share/mypaint-brushes/pkgconfig")
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
