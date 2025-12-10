vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF v${VERSION}
    SHA512 a0778aed525e8b5c6d891a2d6b66b8166a8ea2906f517fd55a61ca04c7939f14425714f4099cbe52c759185b50895010640f8882890a0c6224e02807ea78b9df
    HEAD_REF master
    PATCHES
        dependencies.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gltfpack  MESHOPT_BUILD_GLTFPACK
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMESHOPT_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    OPTIONS_DEBUG
        -DMESHOPT_BUILD_GLTFPACK=OFF # tool
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/meshoptimizer)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if ("gltfpack" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES gltfpack AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
