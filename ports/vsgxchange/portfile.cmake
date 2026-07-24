vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgXchange
    REF "v${VERSION}"
    SHA512 f60bf602b17d5ea404e2d69d58958df136eeb2a73c3374d2820d7d66a11a5e62aaa4f45a7dada09678a69e74a3909744e1cddd206e1cc0f13a216fc9daa1ab01
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        assimp   vsgXchange_assimp
        assimp   VCPKG_LOCK_FIND_PACKAGE_assimp
        curl     vsgXchange_curl
        curl     VCPKG_LOCK_FIND_PACKAGE_CURL
        freetype vsgXchange_freetype
        freetype VCPKG_LOCK_FIND_PACKAGE_Freetype
        gdal     vsgXchange_GDAL
        gdal     VCPKG_LOCK_FIND_PACKAGE_GDAL
        openexr  vsgXchange_openexr
        openexr  VCPKG_LOCK_FIND_PACKAGE_OpenEXR
        ktx      vsgXchange_ktx
        ktx      VCPKG_LOCK_FIND_PACKAGE_Ktx
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DVCPKG_LOCK_FIND_PACKAGE_Doxygen=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_osg2vsg=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_draco=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vsgXchange")

vcpkg_copy_tools(TOOL_NAMES vsgconv AUTO_CLEAN)
vcpkg_clean_executables_in_bin(FILE_NAMES vsgconvd)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
