vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/pugixml
    REF a0e064336317c9347a91224112af9933598714e9 #v1.13.0
    SHA512 9fe2285215520b6ac5f832d457bdfedcf183787a7058bb970a20ea7ca111e1afd864f5b90a4810c79470afefc55c0199febf04d1600634c1ffdbbe000ef6e1df
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPUGIXML_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pugixml)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
