vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpriteOvO/sigmatch
    REF v0.2.0
    SHA512 a2ae12bf2da4de4b4b65f443febca8bec5ded2cdcbfe5c166538869431558241883576fed04fc373b60fe5b5709c96a56110181d3b1c07dbb42ecfdddae74c06
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIGMATCH_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sigmatch)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
