vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://codeberg.org/gumbo-parser/gumbo-parser/archive/${VERSION}.tar.gz"
    FILENAME "gumbo-${VERSION}.tar.gz"
    # Codeberg re-packs the same tag without changing the version string; refresh
    # the hash when download fails with "hash mismatch" (observed 2026-08-02).
    SHA512 9f59965e68ba2e4f5884d52c4126b62cdbefee158816334e317a0d07f10ba927be653490c69fc5b0f52eed1decf0a51715bb726aa84546a2d04cde5805e4a399
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-gumbo CONFIG_PATH share/unofficial-gumbo)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/COPYING")
