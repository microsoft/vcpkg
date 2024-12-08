vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF "tmx_${VERSION}"
    HEAD_REF master
    SHA512 302e55c6d78947dbac1470855331fb238e2ac681f10414aef1e3dad5c1128b66aeb2fef0c4cb2d03360b5e5b327e46c9e5d7dc5bf15d411c9fa3cf7dd4351b4f
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
