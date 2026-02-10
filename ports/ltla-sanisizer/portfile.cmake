vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/sanisizer
    REF "v${VERSION}"
    SHA512 f797d30a9cca159466d0fd72ea32651e256122f0a171be6c57aff1f67f01174088878d80d3492d23c1b39d9f29aabc1ffc6af885868025aecc408be2bc32387a
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
