vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF "v${VERSION}"
    SHA512 248e54e23564660467c7ecf50676b86d3cd10ade89e0ac1d23deb71334cb89cc5eb50f624b385d5119a43ca68ff8b1c74af82dc699b5ccfae54d6dcad4fd9447
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
