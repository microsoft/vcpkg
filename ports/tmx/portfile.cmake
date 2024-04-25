vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF "tmx_${VERSION}"
    HEAD_REF master
    SHA512 9e79b47aa60215c9f2fcc3edf67f680deb25b5d0a841af7a6e6e34b31f3efb4d394b7ab6f577d8a0e299023e09c792089e4ecf185b21ae1a78ef1806f3a07316
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
