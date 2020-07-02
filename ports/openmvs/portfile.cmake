vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF v1.1
    SHA512 baa9149853dc08c602deeb1a04cf57643d1cb0733aee2776f4e99b210279aad3b4a1013ab1d790e91a3a95b7c72b9c12c6be25f2c30a76b69b5319b610cb8e7a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda OpenMVS_USE_CUDA
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DOpenMVS_USE_BREAKPAD=OFF
        -DINSTALL_CMAKE_DIR:STRING=share/openmvs
        -DINSTALL_BIN_DIR:STRING=bin
        -DINSTALL_LIB_DIR:STRING=lib
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
    DensifyPointCloud
    InterfaceCOLMAP
    InterfaceVisualSFM
    ReconstructMesh
    RefineMesh
    TextureMesh
    Viewer
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
