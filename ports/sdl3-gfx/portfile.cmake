vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ferzkopp/SDL3_gfx
    REF "v${VERSION}"
    SHA512 2f5a3bcd6b953568373fd5ad0b0fd4831be05b7f37a8aafadb5ad0e7268fc31a268e0ebd276c9bce92461399a93d1e5324c956b499fd815f4bb97d591eb9af1f
    HEAD_REF main
    PATCHES
        fix-pkgconfig-lm.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL3GFX_SHARED=${BUILD_SHARED}
        -DSDL3GFX_STATIC=${BUILD_STATIC}
        -DSDL3GFX_INSTALL=ON
        -DSDL3GFX_DEMOS=OFF
        -DSDL3GFX_TESTS=OFF
        -DSDL3GFX_BENCH=OFF
        -DSDL3GFX_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SDL3_gfx PACKAGE_NAME SDL3_gfx)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
