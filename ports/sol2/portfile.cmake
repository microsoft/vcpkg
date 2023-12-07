vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF "v${VERSION}"
    SHA512 4404b124a4f331d77459c01a92cd73895301e7d3ef829a0285980f0138b9cc66782de3713d54f017d5aad7d8a11d23eeffbc5f3b39ccb4d4306a955711d385dd 
    HEAD_REF develop
    PATCHES
        fix-namespace.patch
        header-only.patch
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOL2_LUA_VERSION=vcpkg
        -DSOL2_BUILD_LUA=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sol2)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
