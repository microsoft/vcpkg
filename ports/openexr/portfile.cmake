vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openexr
    REF "v${VERSION}"
    SHA512 78f237ce5ec6a4f122d0609bf48c2a9dfcb701e3ce5587906050fbf32d2115dae1984e7cce0f554edda0bd7ec35e4c7aacfc3d1dfb51ea8aa9feebb7f2b3db59
    HEAD_REF main
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
        -DBUILD_WEBSITE=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_libdeflate=ON
        -DOPENEXR_BUILD_EXAMPLES=OFF
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
        TOOL_NAMES
            exr2aces
            # not installed: exrcheck
            exrenvmap
            exrheader
            exrinfo
            exrmakepreview
            exrmaketiled
            exrmanifest
            exrmultipart
            exrmultiview
            exrstdattr
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
