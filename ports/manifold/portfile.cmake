vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF v${VERSION}
    SHA512 920e34f1cc5a34e8081d61a7c362cebca204f5adb8e8862b5f0f1e3fc28be4a3b0511fd84d8a6da486c1ff0696206a6c2f75f3f53d61a35a29f7564ece62717e
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
