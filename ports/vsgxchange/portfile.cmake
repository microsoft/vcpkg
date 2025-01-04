vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgXchange
    REF "v${VERSION}"
    SHA512 a4c79092162c64f745556fa64b10fd06906526f5f7b7e22e61fc34f42d50116fe1816ff5cb0ca862f7da6a4a221818e99867e8520da4ffc2b9867ef15a01cd13
    HEAD_REF master
    PATCHES require-features.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        assimp   VSGXCHANGE_WITH_ASSIMP
        curl     VSGXCHANGE_WITH_CURL
        freetype VSGXCHANGE_WITH_FREETYPE
        gdal     VSGXCHANGE_WITH_GDAL
        openexr  VSGXCHANGE_WITH_OPENEXR
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "vsgXchange" CONFIG_PATH "lib/cmake/vsgXchange")
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES vsgconv AUTO_CLEAN)
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/vsgconvd${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
