vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kaaserne/cpp-lazy
    REF "v${VERSION}"
    SHA512 d5ad743805df55178b3758e9ad9e5cdc001821d3bb2bb284fa0c5709780edb1896d4695582ce26849eecec287b9bd41b646e7f9d166b897bab82a93fe37ed37b
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPP_LAZY_INSTALL=ON
        -DCPP_LAZY_USE_INSTALLED_FMT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpp-lazy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
