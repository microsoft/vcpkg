vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF d0f32a5a43d1b9dc0b2cd6af310e5f09b97c3423
    SHA512 c4d4bb1a54ae95f47223636c51c8ad611d2a8d698e9dbdc2d3fd06946b23d34b78af930762eb7f98cb49ae0a78948a668b1c44e1bb590069d5dd90dbcbb078ab
    HEAD_REF master
    PATCHES pkgconfig.patch
            fix-clang-cl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
