vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF "v${VERSION}"
    SHA512 50e68afc5d24e9c963336a2e4dba6e2656d2046278679bc081fc66dae1ffb0ee75176699bde79340346e538ced15a7072dc298e6be7e4d3e80f9df5163e09396
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME tsl-robin-map CONFIG_PATH share/cmake/tsl-robin-map)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
