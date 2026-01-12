vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/thermo-cpp
    REF "v${VERSION}"
    SHA512 0e27b256aacf51fd25a619ba7bd7959c1bf4ce4d491d817664ebe7c90911753d15b051d312c56dd7f8a0dc33f9108c5ee32b53188b868f02913e4026fa4351c5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTHERMO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME thermo CONFIG_PATH lib/cmake/thermo)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
