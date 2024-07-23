vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hjson/hjson-cpp
    REF "${VERSION}"
    SHA512 89b13091c1c89007b8be71b9e9e2d86e69226f9a4479b52357981c04d3409dc9ba8b709eaa96ed547b9b68a548991d75224596920186d8109f99380c646c9956
    HEAD_REF master
    PATCHES
        fix-runtime-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHJSON_ENABLE_INSTALL=ON
        -DHJSON_ENABLE_TEST=OFF
        -DHJSON_ENABLE_PERFTEST=OFF
        -DHJSON_VERSIONED_INSTALL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME hjson CONFIG_PATH lib/hjson)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
