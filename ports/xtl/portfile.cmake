# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtl
    REF "${VERSION}"
    SHA512 d7155d5fbaaeb54caf799823e2020f1bcbb6eaeaa2be3b22625f9056faf001847c6ef749bc14f68feccec924a1faf551f27c4ee7f6f33da5d2dcfbc112824069
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
