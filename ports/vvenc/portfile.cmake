vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraunhoferhhi/vvenc
    REF v${VERSION}
    SHA512 2b73f10a32da28bdc51913b5ecc229fe56ef0afe0d66a9bb1e76a9044dc04427e55587b6b9a0ca8d315220d4362b663e038a68a89e5b38ecf3ed2e7b5dcb0c58
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools  BUILD_TOOLS
)

if(BUILD_TOOLS)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DCCACHE_FOUND=OFF
        -DVVENC_ENABLE_THIRDPARTY_JSON=SYSTEM
        -DVVENC_LIBRARY_ONLY=OFF
        -DVVENC_INSTALL_FULLFEATURE_APP=ON
)
else()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DCCACHE_FOUND=OFF
        -DVVENC_ENABLE_THIRDPARTY_JSON=SYSTEM
        -DVVENC_LIBRARY_ONLY=ON
)
endif()


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vvenc)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vvencFFapp vvencapp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
