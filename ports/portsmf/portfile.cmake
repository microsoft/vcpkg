vcpkg_download_distfile(ARCHIVE
    URLS "https://codeberg.org/tenacityteam/portsmf/archive/${VERSION}.tar.gz"
    FILENAME "${VERSION}.tar.gz"
    SHA512 522ef6e92de6497c66d6b9adf2b6b4e419024d26fac421096718b024ea0e183d322d3f0cd9fc357e0ba983371cf313d7a0b93b8b24aff5c9cb1ab61c915725ff
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"

)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortSMF)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
