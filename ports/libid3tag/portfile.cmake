vcpkg_download_distfile(
    ARCHIVE URLS "https://codeberg.org/tenacityteam/libid3tag/archive/${VERSION}.tar.gz"
    FILENAME "${VERSION}.tar.gz"
    SHA512 d49bc637899e4251ed66b5b56aa4c910dcdecd6b03ed197866d74175fc4eadff40f40f336606b23e2505b0e11834c4212a1314feeeaa2c0e9713051fdb56cb45
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME id3tag CONFIG_PATH lib/cmake/id3tag)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
