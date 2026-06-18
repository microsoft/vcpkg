vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF "v${VERSION}"
    SHA512 10a3b1ecbe3f6f11f42e97dc22d0a2e7fcb6a66d4ae3ed95f56594477ac20ba91d6bcb5fe932e42c0dc431d262973813e67955919200f97337878416c9c7ec03
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
