vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgXchange
    REF "v${VERSION}"
    SHA512 6132f713c99b4953344111e9c8e4eb73bba320576dcffd15b12bb45d857ff9142d2d02ce9fa76362c43d80cf0f3c1103981e3c73a4182842ebe6121e8c4f6bd8
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        assimp   vsgXchange_assimp
        assimp   CMAKE_REQUIRE_FIND_PACKAGE_assimp
        curl     vsgXchange_curl
        curl     CMAKE_REQUIRE_FIND_PACKAGE_CURL
        freetype vsgXchange_freetype
        freetype CMAKE_REQUIRE_FIND_PACKAGE_Freetype
        gdal     vsgXchange_GDAL
        gdal     CMAKE_REQUIRE_FIND_PACKAGE_GDAL
        openexr  vsgXchange_openexr
        openexr  CMAKE_REQUIRE_FIND_PACKAGE_OpenEXR
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
        -DCMAKE_DISABLE_FIND_PACKAGE_osg2vsg=1
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vsgXchange")
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES vsgconv AUTO_CLEAN)
vcpkg_clean_executables_in_bin(FILE_NAMES vsgconvd)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
