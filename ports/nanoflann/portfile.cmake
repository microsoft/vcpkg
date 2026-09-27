vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF "${VERSION}"
    SHA512 7131a5fede0bae2b420824d188f025c4dfb071832a08cd468a63ad483ae5814f317454ce48c639dd4bef45862aca434d57f73574fb50b9dd568eb4db54bcc241
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOFLANN_BUILD_EXAMPLES=OFF
        -DNANOFLANN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
