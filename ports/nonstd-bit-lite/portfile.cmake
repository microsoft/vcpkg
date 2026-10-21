set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nonstd-lite/bit-lite
    REF "v${VERSION}"
    SHA512 a0b9f5786e72ffa1dcd77f7bd62ad08160a845c4fb05ff0b6fe7233c80aed89b7df6e698eed9ff633dd9e7ffaf19fa866d93d5d541d0a5af0d79afd5f76425e3
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
