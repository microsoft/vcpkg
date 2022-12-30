vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO globberwops/dynamic-loader
    REF "v${VERSION}"
    SHA512 be133edf9eb3e93c05440c970a10492c258128bfb4417578c4e93eec8b884febd0be80c1fa7b0cce5ef5fd03ed0b4dbd23e68d3594fe7c93f15c9339e95867d1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDynamicLoader_BUILD_DOCS=OFF
        -DDynamicLoader_BUILD_TESTS=OFF
        -DDynamicLoader_ENABLE_WARNINGS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME DynamicLoader
    CONFIG_PATH lib/cmake/DynamicLoader
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)
