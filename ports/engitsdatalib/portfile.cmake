vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO enGits/enGitsDataLib
    REF v1.0.1
    SHA512 bd1a59741d3286995e2fdeea03822f2a25f022c87938ccd77f41c97c29d9526dfa1a5d6f71c9fdf2c44c4d05ae580624d42cde51bc805f95bee152111f9bab97
    HEAD_REF master
    PATCHES
        use-system-doctest.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" EDL_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCREATE_STATIC_LIBRARY=${EDL_BUILD_STATIC}"
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME enGitsDataLib
    CONFIG_PATH lib/cmake/enGitsDataLib
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
