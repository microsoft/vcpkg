vcpkg_download_distfile(
    ARCHIVE URLS "https://codeberg.org/tenacityteam/libid3tag/releases/download/${VERSION}/id3tag-${VERSION}-source.tar.gz"
    FILENAME "id3tag-${VERSION}-source.tar.gz"
    SHA512 14f51b0c01ce931f563029976fa76f4a30e6fac7d5ad2ef9beff53bd6d1d0f7a3f9a9266a06dcf9018f306d5d3eb8467ced8d6f3aa5160a637873eb02e330c87
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME id3tag CONFIG_PATH lib/cmake/id3tag)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
