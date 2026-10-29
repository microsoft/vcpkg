vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kosma/minmea
    REF "v1.0.0"
    SHA512 5a3018ec4402d87f8c2ca19090e384e8d7a3c0c7b79822a8e8531517e3781b1e04f8dd125ed3c012ddfde81479f061dbefdbf951a1b205eb68b9e9de7681c641
    HEAD_REF master
    PATCHES
        0001-Update-CMake-configuration-to-version-3.10-and-enhan.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMINMEA_ENABLE_TESTING=OFF
        -DMINMEA_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME minmea
    CONFIG_PATH lib/cmake/minmea
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.grants"
        "${SOURCE_PATH}/LICENSE.MIT"
        "${SOURCE_PATH}/LICENSE.LGPL-3.0"
        "${SOURCE_PATH}/COPYING"
)
