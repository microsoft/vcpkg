if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charles-lunarg/vk-bootstrap
    REF "v${VERSION}"
    SHA512 5490b7f1cc8cda81c1cbf58beb8169c0627dc894752b58aff1c007e258426cac355d6ee5ae80aba138654f37852448329a8e0df3e57360cbcc768b1a7d7e2c6d
    HEAD_REF master
    PATCHES
        fix-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVK_BOOTSTRAP_TEST=OFF
        -DVK_BOOTSTRAP_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
