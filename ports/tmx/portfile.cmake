vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF "tmx_${VERSION}"
    HEAD_REF master
    SHA512 215a05c31ed52a1701fdc8014661f744f43095aa7756e3034a33f4e0d4b27d405b1283fa143fe1d73703aedf0ecdca1a55db34f8dafe186bebcf673fe007e2e6
    PATCHES
        libxml2.patch
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
