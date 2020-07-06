vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF v1.1
    SHA512 baa9149853dc08c602deeb1a04cf57643d1cb0733aee2776f4e99b210279aad3b4a1013ab1d790e91a3a95b7c72b9c12c6be25f2c30a76b69b5319b610cb8e7a
    HEAD_REF master
    PATCHES
       fix-tool-paths.patch
       fix-linux-build.patch
       fix-tool-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda   OpenMVS_USE_CUDA
    openmp OpenMVS_USE_OPENMP
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DOpenMVS_USE_BREAKPAD=OFF
        -DINSTALL_CMAKE_DIR:STRING=share/openmvs
        -DINSTALL_BIN_DIR:STRING=bin
        -DINSTALL_LIB_DIR:STRING=lib
    OPTIONS_RELEASE
        -DOpenMVS_BUILD_TOOLS=ON
    OPTIONS_DEBUG
        -DOpenMVS_BUILD_TOOLS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()
file(READ ${CURRENT_PACKAGES_DIR}/share/openmvs/OpenMVSTargets-release.cmake TARGETS_CMAKE)
string(REPLACE "bin/InterfaceCOLMAP.exe" "tools/openmvs/InterfaceCOLMAP.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/InterfaceVisualSFM.exe" "tools/openmvs/InterfaceVisualSFM.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/DensifyPointCloud.exe" "tools/openmvs/DensifyPointCloud.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/ReconstructMesh.exe" "tools/openmvs/ReconstructMesh.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/RefineMesh.exe" "tools/openmvs/RefineMesh.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/TextureMesh.exe" "tools/openmvs/TextureMesh.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/Viewer.exe" "tools/openmvs/Viewer.exe" TARGETS_CMAKE "${TARGETS_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/openmvs/OpenMVSTargets-release.cmake "${TARGETS_CMAKE}")

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
    DensifyPointCloud
    InterfaceCOLMAP
    InterfaceVisualSFM
    ReconstructMesh
    RefineMesh
    TextureMesh
    Viewer
)

set(OPENMVG_TOOLS_PATH "${CURRENT_INSTALLED_DIR}/tools/openmvg")
set(OPENMVS_TOOLS_PATH "${CURRENT_INSTALLED_DIR}/tools/${PORT}")
set(SENSOR_WIDTH_CAMERA_DATABASE_TXT_PATH "${OPENMVG_TOOLS_PATH}/sensor_width_camera_database.txt")
configure_file("${SOURCE_PATH}/MvgMvsPipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/MvgMvsPipeline.py" @ONLY)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
