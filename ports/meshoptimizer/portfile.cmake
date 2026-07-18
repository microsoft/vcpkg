vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF "v${VERSION}"
    SHA512 23197a9dcd4cbbce625b9d142f2eaafc67c9cf92859f9a5ce94c4570fca8db07c97590d2737d97726dbf48e968f53c8d7dd26771678c2cade957c62a3600d88c
    HEAD_REF master
    PATCHES
        dependencies.diff
)

file(READ "${SOURCE_PATH}/CMakeLists.txt" _cmake)
string(REPLACE
    "set_target_properties(gltfpack PROPERTIES CXX_STANDARD 11)"
    "set_target_properties(gltfpack PROPERTIES CXX_STANDARD 11 NO_SYSTEM_FROM_IMPORTED ON)"
    _cmake "${_cmake}"
)
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${_cmake}")

if ("gltfpack" IN_LIST FEATURES)
    # gltfpack needs symbols not in a released cgltf/fast-obj tag yet; patch local copies here
    # rather than the shared ports so other cgltf/fast-obj consumers are unaffected.
    file(COPY "${CURRENT_INSTALLED_DIR}/include/cgltf.h" "${CURRENT_INSTALLED_DIR}/include/fast_obj.h" DESTINATION "${SOURCE_PATH}/gltf")

    vcpkg_apply_patches(
        SOURCE_PATH "${SOURCE_PATH}"
        PATCHES
            cgltf-meshopt-color.diff
            fastobj-face-lines.diff
    )
endif()

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
