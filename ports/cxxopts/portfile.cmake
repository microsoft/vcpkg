vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF "v${VERSION}"
    SHA512 7265de66b92591255488d01bc26ca874423c75223e2e157a99f14fdd3e92e8d2669b72732acac3ce835190f1a09c13a994c480f0513f229eba8aa008e3d98955
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCXXOPTS_BUILD_EXAMPLES=OFF
        -DCXXOPTS_BUILD_TESTS=OFF
        -DCXXOPTS_ENABLE_WARNINGS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cxxopts)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
