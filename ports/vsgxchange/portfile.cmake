vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgXchange
    REF "v${VERSION}"
    SHA512 488bdc9fdbd61cc083675b2970cea9ab307827aa80f05220a21d6f831d308e1bb8e65c288f96e37561903759212b9f5f1269eb4fcf898b8c91b1e50733c71c40
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
