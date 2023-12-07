vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF eba86625b707e3c8c99bbfc4624e51f42dc9e561 #v3.3.0
    SHA512 a1fbcb4efd9a8b8b97c351e90499644aea72a3db62c258e219a2912853936b76870b51e69d835c14cbf1a20733673ba474e259a0243fec419c411b995cd1511d 
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
