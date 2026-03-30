vcpkg_download_distfile(
    ARCHIVE URLS "https://codeberg.org/tenacityteam/libid3tag/archive/${VERSION}.tar.gz"
    FILENAME "${VERSION}.tar.gz"
    SHA512 056b7e00c62d14fc09980d4309422c822ad485cca3876cbb76017fef89aaf79ecfb42f2683521ff6d19f172ff1b7435dbd7307449559099ad31e0058415918ec
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME id3tag CONFIG_PATH lib/cmake/id3tag)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
