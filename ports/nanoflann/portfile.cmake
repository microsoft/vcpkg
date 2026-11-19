vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF "${VERSION}"
    SHA512 05e83b00b472283f02118d61e897a2c0e36249ff5ad43cbe040b4ff3430d16f36b152a1a04ea5bc2391f6277141579a7e25248fb5a9efd5426b3c7264b6ccb83
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
