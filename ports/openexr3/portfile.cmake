vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openexr
    REF v3.1.5
    SHA512 01ef16eacd2dde83c67b81522bae87f47ba272a41ce7d4e35d865dbdcaa03093e7ac504b95d2c1b3a19535f2364a4f937b0e0570c74243bb1c6e021fce7b620c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_INCLUDEDIR=include/openexr3
        -DBUILD_TESTING=OFF
        -DOPENEXR_INSTALL_EXAMPLES=OFF
        -DDOCS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenEXR)
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    TOOL_NAMES exrenvmap exrheader exrinfo exrmakepreview exrmaketiled exrmultipart exrmultiview exrstdattr exr2aces
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
