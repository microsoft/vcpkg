vcpkg_download_distfile(ARCHIVE
    URLS "http://0pointer.de/lennart/projects/libdaemon/libdaemon-${VERSION}.tar.gz"
    FILENAME "libdaemon-${VERSION}.tar.gz"
    SHA512 a96b25c09bd63cc192c1c5f8b5bf34cc6ad0c32d42ac14b520add611423b6ad3d64091a47e0c7ab9a94476a5e645529abccea3ed6b23596567163fba88131ff2
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
