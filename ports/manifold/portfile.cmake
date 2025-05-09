vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF v${VERSION}
    SHA512 c35523c4d314b670639371b6906c98eb3ff4e4785689460940101f9a5f9b071805697d8af4e7eb6e87b0ef8590b4a22575e42f8314fc1f93220febf77fb313f7
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMANIFOLD_TEST=OFF
        -DMANIFOLD_CROSS_SECTION=ON
        -DMANIFOLD_CBIND=ON
        -DMANIFOLD_PYBIND=OFF
        -DMANIFOLD_JSBIND=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/manifold)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
