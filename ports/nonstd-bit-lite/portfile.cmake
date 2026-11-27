set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nonstd-lite/bit-lite
    REF "v${VERSION}"
    SHA512 3d993841f436961d95931dda30b4e5a1c8b07f1a6a8cf326168a8ee01307c461c94ed7e0fde221263b4164bb86efb1801f452c7c1414f769a6a98fb25c0ef6e2
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
