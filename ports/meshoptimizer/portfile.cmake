# gltfpack needs cgltf_meshopt_compression_filter_color and fastObjMesh::face_lines,
# neither of which is in a released cgltf/fast-obj tag yet. meshoptimizer's upstream
# repo vendors matching copies of both under extern/, so build against those instead of
# the vcpkg cgltf/fast-obj ports to avoid patching or pinning them to an unreleased commit.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF "v${VERSION}"
    SHA512 23197a9dcd4cbbce625b9d142f2eaafc67c9cf92859f9a5ce94c4570fca8db07c97590d2737d97726dbf48e968f53c8d7dd26771678c2cade957c62a3600d88c
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

vcpkg_install_copyright(COMMENT [[
meshoptimizer is provided under MIT license terms.
gltfpack vendors cgltf and fast_obj (both MIT); their license notices are in the headers below.]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
        "${SOURCE_PATH}/extern/cgltf.h"
        "${SOURCE_PATH}/extern/fast_obj.h"
)
