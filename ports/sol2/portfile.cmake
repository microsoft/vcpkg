vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF "v${VERSION}"
    SHA512 5a6ec7e16dae05ad6abea02842f62db8f64935eda438d67b2c264cbee80cee6d82200bd060387c6df837fe9f212dbe22b2772af34df1ce8bd43296dd9429558d
    HEAD_REF develop
    PATCHES
        header-only.patch
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sol2)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
