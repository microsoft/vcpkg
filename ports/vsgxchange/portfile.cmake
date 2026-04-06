vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgXchange
    REF "v${VERSION}"
    SHA512 ed58e22492cad33e25e50e9d651b2c820aec0632ccf432a3b99bcdf653e6e645b86d6ac4c1e9a8f9d0fdec6b1baef9ebaf3afd3ebe19059ec822686904684bbe
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
