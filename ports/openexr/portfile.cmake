vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openexr
    REF "v${VERSION}"
    SHA512 6e0a6fdcfae57c6e8b060d9aeed57140d96d39bffe5e40edd6ea5beb06e569323833d07906316ffca05f48e8409d0ea4174e2cd84d554404a4ee432e07d7b5e6
    HEAD_REF main
    PATCHES
        fix-cmake-package.patch # https://github.com/AcademySoftwareFoundation/openexr/pull/1674
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        tools   OPENEXR_BUILD_TOOLS
        tools   OPENEXR_INSTALL_TOOLS
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DBUILD_TESTING=OFF
        -DOPENEXR_INSTALL_EXAMPLES=OFF
        -DBUILD_WEBSITE=OFF
        -DOPENEXR_INSTALL_PKG_CONFIG=ON
    OPTIONS_DEBUG
        -DOPENEXR_BUILD_TOOLS=OFF
        -DOPENEXR_INSTALL_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenEXR)

vcpkg_fixup_pkgconfig()

if(OPENEXR_INSTALL_TOOLS)
    vcpkg_copy_tools(
        TOOL_NAMES exrenvmap exrheader exrinfo exrmakepreview exrmaketiled exrmultipart exrmultiview exrstdattr exr2aces
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
