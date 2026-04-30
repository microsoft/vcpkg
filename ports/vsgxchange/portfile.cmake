vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgXchange
    REF "v${VERSION}"
    SHA512 d95d827aa1b359e32180d805551fc112fc584a50f1c9a7e40bc5bb481ca1f68c69c15025cbbf14735e273ba6fb4ec94c8e8c85f7bddc562a1ee5d6b24348083e
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
