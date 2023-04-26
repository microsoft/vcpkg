vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DatabaseGroup/tree-similarity
    REF 76e62627438ea603c9881221f7444c7cb5407b6d
    SHA512 e344b949e390d2494f3d3568359d9f520cb459863f47c150034bffb263a2a71bc86bb60dbac673f30c55cf4e2a26b45ea39593928e42fb2121edb605dd4765ee
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
