vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF "tmx_${VERSION}"
    HEAD_REF master
    SHA512 3f91faa711ad35ba0a46ae7a6e15f11928340e2d05c1202ef05cd8e9e08ce62d4ef6ef7bd743ca18fed3cab12af3201090bf556a2929ece3f010112728351577
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tmx)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
