vcpkg_download_distfile(ARCHIVE
    URLS "https://codeload.github.com/mariadb-corporation/mariadb-connector-cpp/tar.gz/refs/tags/${VERSION}"
    FILENAME "mariadb-connector-cpp-${VERSION}.tar.gz"
    SHA512 380380fb5f48db8a0e38de4db122207bc076df64ea1ad0d7c74180cf6d1a9c16868c107d32a563ff8b16454cd5089b029d2977f6022dfd27c6b49e243956ba20
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")