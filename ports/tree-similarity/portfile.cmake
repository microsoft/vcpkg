vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DatabaseGroup/tree-similarity
    REF 76e62627438ea603c9881221f7444c7cb5407b6d
    SHA512 0
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tree-similarity)
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
