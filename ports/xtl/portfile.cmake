# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtl
    REF "${VERSION}"
    SHA512 cb032d27b2f7dff135c442fd92e3924eb108355769354c9eee9ec2d3ec7ebd867ee89ee2e10f41352447e08f185637f338fdc40e37d60d85cf2fffdcaac1ce6c
    HEAD_REF master
    PATCHES
        fix-fixup-cmake.patch
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/xtl)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
