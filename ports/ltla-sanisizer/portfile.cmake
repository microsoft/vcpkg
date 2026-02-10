vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/sanisizer
    REF "v${VERSION}"
    SHA512 9f1ec450d34c208101c38c035269da7f856dc95d7f9c34c5323fded8287c9ea14caedfe563886cdd890aae1b4137f55c269f91717caa106743449b42c30aafc6
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSANISIZER_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_sanisizer
    CONFIG_PATH lib/cmake/ltla_sanisizer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
