vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO likle/cargs
    REF "v${VERSION}"
    SHA512 936fa94da31b07de27c0278688199705f9fdc55cf248c7a88405c373e5c77eed2a703d9398d3ea80a3a534db3d542898babb49db268d26c5945c4907540ccc1b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cargs)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
