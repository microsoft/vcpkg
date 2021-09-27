set(OPENSP_VERSION 1.5.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/openjade/opensp/${OPENSP_VERSION}/OpenSP-${OPENSP_VERSION}.tar.gz"
    FILENAME "OpenSP-${OPENSP_VERSION}.tar.gz"
    SHA512 a7dcc246ba7f58969ecd6d107c7b82dede811e65f375b7aa3e683621f2c6ff3e7dccefdd79098fcadad6cca8bb94c2933c63f4701be2c002f9a56f1bbe6b047e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${OPENSP_VERSION}
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-doc-build
        --enable-http
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
