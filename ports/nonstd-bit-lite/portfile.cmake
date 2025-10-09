set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nonstd-lite/bit-lite
    REF "v${VERSION}"
    SHA512 96706a536891cdeaa7a3c2285a610b0fcf0a7096fe89aca8eef6d8c8db89c71263d3eaa2fc97cdd80992a0ce196a0e3aaa979b48e452820302fd7db891c7b761
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBIT_LITE_OPT_BUILD_TESTS=OFF
        -DBIT_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME bit-lite
    CONFIG_PATH lib/cmake/bit-lite
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
