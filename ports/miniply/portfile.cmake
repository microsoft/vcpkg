vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vilya/miniply
    REF 1a235c70390fadf789695c9ccbf285ae712416b3
    SHA512 856bb39bd36dab588026b9ee886a996bd697df5c1a24de2abff822e037a0fb7af0be19dca5e2f6ccc524453b0b9ee6e225510565ca78f6b965dd7406ba67dac1
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-miniply)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
