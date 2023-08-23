vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF "v.${VERSION}"
    SHA512 0d69567a68f17f3ad30978f1ee165e673f77332f519c2e9429284d87886f90c0dea46b8dcaedb55cf4c1611eca79b9196178e37deb56ad89272ca19382f290bc
    PATCHES
        fix-cmake-config.diff
        fix-project.diff
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
