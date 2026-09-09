vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF "v${VERSION}"
    SHA512 837eaba3df67046aaed4e2912c68e8f9415218a524674442c56d8c31430a804fc70c405439c59584ad0d5219bee16b60bccd68e40ce9c8c2548c23f1b1006768
    PATCHES
        fix-pkgconfig-cflags.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMANIFOLD_TEST=OFF
        -DMANIFOLD_CROSS_SECTION=ON
        -DMANIFOLD_CBIND=ON
        -DMANIFOLD_PYBIND=OFF
        -DMANIFOLD_JSBIND=OFF
        -DMANIFOLD_STRICT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/manifold)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
