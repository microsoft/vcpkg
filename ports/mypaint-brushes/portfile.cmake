set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mypaint/mypaint-brushes/releases/download/v${VERSION}/mypaint-brushes-${VERSION}.tar.xz"
    FILENAME "mypaint-brushes-${VERSION}.tar.xz"
    SHA512 bae870e930381b818165e5e39d38b25782d5744c9a507a71dab37ae7ca2d4502896057f919a16eb9305d803a01db3a948a735d5c5b850893997a9afd6403144b
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
file(RENAME "${CURRENT_PACKAGES_DIR}/share/mypaint-brushes/pkgconfig/mypaint-brushes-2.0.pc" "${CURRENT_PACKAGES_DIR}/share/pkgconfig/mypaint-brushes-2.0.pc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/" "${CURRENT_PACKAGES_DIR}/share/mypaint-brushes/pkgconfig")
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
