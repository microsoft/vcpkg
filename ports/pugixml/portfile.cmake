vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/pugixml
    REF a0e064336317c9347a91224112af9933598714e9 #v1.13.0
    SHA512 7ac529624db44637ae265c8a5e47873b768a355e291f726195e9f9aed126f5c45057bc7141f7db66d90afe13a959107c397a2dddbd3dff826dcb26fdf7c41fdc
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
