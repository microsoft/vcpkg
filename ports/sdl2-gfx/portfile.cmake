vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ferzkopp/SDL2_gfx
    REF "v${VERSION}"
    SHA512 a7244eb4b4c497df041dfd153af6bbd47704fd7381ce0045b752158f39901c32d9b662a1af4d03d7fc6e443d3781ce1e61af73df449395bb9418159e2ae0c5f1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL2GFX_SHARED=${BUILD_SHARED}
        -DSDL2GFX_STATIC=${BUILD_STATIC}
        -DSDL2GFX_INSTALL=ON
        -DSDL2GFX_DEMOS=OFF
        -DSDL2GFX_TESTS=OFF
        -DSDL2GFX_BENCH=OFF
        -DSDL2GFX_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SDL2_gfx PACKAGE_NAME SDL2_gfx)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
