vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF "v${VERSION}"
    SHA512 c77dba232537e71f930a9a54f4e7575debcac10bbfa67f002a3b7262889871d146de583b774b5c8a0b5bf5a7471ee17c375bda6bb4f3f3cf52e1d33313231be2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME tsl-robin-map CONFIG_PATH share/cmake/tsl-robin-map)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
