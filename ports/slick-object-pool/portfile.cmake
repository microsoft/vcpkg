set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-object-pool
    REF "v${VERSION}"
    SHA512 d3fb8cbd3e0b05a4ba8658a3d10c474e1e111235741e6e0a426f770ccf4053f15c07ef22ba4f44ba4389bc5513448e9bd2dc33873f645a192ead49c81fda978b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_OBJECTPOOL_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/slick-object-pool)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
