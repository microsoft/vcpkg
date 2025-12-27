vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF "v${VERSION}"
    SHA512 95d83c6694b63b6fd27657c4c5e22ddbc078d26b7324b8f17952a6c7e4547028698aa155077c0cfb916d3497ca31c365e0cbcd81f3cbe959ef40a7ee2e5cd300
    HEAD_REF master
    PATCHES
        fix-build.patch
        no-absolute-paths.patch
        fix-static-build.patch
        fix-lib-name-conflict.patch
        fix-eigen3.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda   OpenMVS_USE_CUDA
        openmp OpenMVS_USE_OPENMP
        nonfree OpenMVS_USE_NONFREE
        ceres OpenMVS_USE_CERES
)

file(REMOVE "${SOURCE_PATH}/build/Modules/FindCERES.cmake")
file(REMOVE "${SOURCE_PATH}/build/Modules/FindCGAL.cmake")
file(REMOVE "${SOURCE_PATH}/build/Modules/FindEIGEN.cmake")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(USE_SSE ON)
else()
    set(USE_SSE OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -DOpenMVS_USE_FAST_FLOAT2INT=ON
        -DOpenMVS_USE_FAST_INVSQRT=OFF
        -DOpenMVS_USE_FAST_CBRT=ON
        -DOpenMVS_USE_SSE=ON
        -DOpenMVS_USE_OPENGL=ON
        -DOpenMVS_USE_BREAKPAD=OFF
        -DOpenMVS_ENABLE_TESTS=OFF
        -DOpenMVS_USE_SSE=${USE_SSE}
    OPTIONS_RELEASE
        -DOpenMVS_BUILD_TOOLS=ON
    OPTIONS_DEBUG
        -DOpenMVS_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_cmake_config_fixup()
file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenMVSTargets-release.cmake TARGETS_CMAKE)
string(REPLACE "bin/InterfaceCOLMAP" "tools/${PORT}/InterfaceCOLMAP" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/InterfaceMetashape" "tools/${PORT}/InterfaceMetashape" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/InterfaceMVSNet" "tools/${PORT}/InterfaceMVSNet" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/DensifyPointCloud" "tools/${PORT}/DensifyPointCloud" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/ReconstructMesh" "tools/${PORT}/ReconstructMesh" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/RefineMesh" "tools/${PORT}/RefineMesh" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/TextureMesh" "tools/${PORT}/TextureMesh" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/TransformScene" "tools/${PORT}/TransformScene" TARGETS_CMAKE "${TARGETS_CMAKE}")
string(REPLACE "bin/Viewer" "tools/${PORT}/Viewer" TARGETS_CMAKE "${TARGETS_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenMVSTargets-release.cmake "${TARGETS_CMAKE}")

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
    DensifyPointCloud
    InterfaceCOLMAP
    InterfaceMetashape
    InterfaceMVSNet
    ReconstructMesh
    RefineMesh
    TextureMesh
    TransformScene
    Viewer
)

set(OPENMVG_TOOLS_PATH "${CURRENT_INSTALLED_DIR}/tools/openmvg")
set(OPENMVS_TOOLS_PATH "${CURRENT_INSTALLED_DIR}/tools/${PORT}")
set(SENSOR_WIDTH_CAMERA_DATABASE_TXT_PATH "${OPENMVG_TOOLS_PATH}/sensor_width_camera_database.txt")
configure_file("${SOURCE_PATH}/MvgMvsPipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/MvgMvsPipeline.py" @ONLY)
configure_file("${SOURCE_PATH}/MvgOptimizeSfM.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/MvgOptimizeSfM.py" @ONLY)
file(INSTALL "${SOURCE_PATH}/build/Modules/FindVCG.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
