# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtl
    REF "${VERSION}"
    SHA512 07c2a68db3dbac556dbb0397e54792ddc7a3e87573bff04faa4262dc433b710392ff9c915d428f5abd1ae892ac9bc7744645e75fdb2bb2cee83c523e087c793e
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
