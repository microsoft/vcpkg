set(VERSION 0.30)

vcpkg_download_distfile(ARCHIVE
    URLS "http://0pointer.de/lennart/projects/${PORT}/${PORT}-${VERSION}.tar.xz"
    FILENAME "${PORT}-0.30.tar.xz"
    SHA512 f7543582122256826cd01d0f5673e1e58d979941a93906400182305463d6166855cb51f35c56d807a56dc20b7a64f7ce4391368d24990c1b70782a7d0b4429c2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${VERSION}
)

set(ENV{GTKDOCIZE} true)
vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gtk-doc
        --enable-gtk-doc=no        
        --disable-lynx
        --disable-silent-rules
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
