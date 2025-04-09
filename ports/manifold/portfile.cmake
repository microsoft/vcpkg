vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF v${VERSION}
    SHA512 881d3b0e3ff03794ce66b09c4a7be675e5dcd5d5b269d62ad5c5de177e76a01460f6f0fb55a2973a92abda3bf32b8a08bafdff5c0b379ae095d9806eb5669022
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
