if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)  # needs fixes
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF "v${VERSION}"
    SHA512 c8af808393836d0ac508cf4f1d123cf297b451927fe4ad95dd27e041099818cd6d077f95b03e34cd9fe92bf0277cce8e9386311531093d6469b8e07f08b15aba
    HEAD_REF master
    PATCHES
        ambiguous-uint_t.diff
        cmake.diff
        common-log.diff
        devendor.diff
        interface-metashape.diff
        missing-include.diff
        no-absolute-paths.patch
)
file(REMOVE "${SOURCE_PATH}/build/Modules/FindEigen3.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ceres       OpenMVS_USE_CERES
        ceres       VCPKG_LOCK_FIND_PACKAGE_Ceres
        cuda        OpenMVS_USE_CUDA
        cuda        VCPKG_LOCK_FIND_PACKAGE_CUDA
        opengl      OpenMVS_USE_OPENGL
        opengl      VCPKG_LOCK_FIND_PACKAGE_OpenGL
        openmp      OpenMVS_USE_OPENMP
        openmp      VCPKG_LOCK_FIND_PACKAGE_OpenMP
        tools       OpenMVS_BUILD_TOOLS
        viewer      VCPKG_LOCK_FIND_PACKAGE_GLEW
        viewer      VCPKG_LOCK_FIND_PACKAGE_GLFW
)

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

set(USE_SSE OFF)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(USE_SSE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW  # MSVC runtime, needed for CUDA
        -DCMAKE_POLICY_DEFAULT_CMP0167=NEW  # Boost
        -DCMAKE_POLICY_DEFAULT_CMP0177=NEW  # install() DESTINATION
        -DINSTALL_CMAKE_DIR:STRING=share/openmvs
        -DINSTALL_INCLUDE_DIR:STRING=include/openmvs
        -DOpenMVS_ENABLE_TESTS=OFF
        -DOpenMVS_USE_BREAKPAD=OFF
        -DOpenMVS_USE_FAST_CBRT=ON
        -DOpenMVS_USE_FAST_FLOAT2INT=ON
        -DOpenMVS_USE_FAST_INVSQRT=OFF
        -DOpenMVS_USE_PYTHON=OFF
        -DOpenMVS_USE_SSE=${USE_SSE}
        -DVCPKG_LOCK_FIND_PACKAGE_JPEG=ON
        -DVCPKG_LOCK_FIND_PACKAGE_OpenGL=ON
        -DVCPKG_LOCK_FIND_PACKAGE_PNG=ON
        -DVCPKG_LOCK_FIND_PACKAGE_TIFF=ON
    OPTIONS_DEBUG
        -DOpenMVS_BUILD_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        # subject to features
        VCPKG_LOCK_FIND_PACKAGE_Ceres
        VCPKG_LOCK_FIND_PACKAGE_CUDA
        VCPKG_LOCK_FIND_PACKAGE_GLEW
        VCPKG_LOCK_FIND_PACKAGE_GLFW
        VCPKG_LOCK_FIND_PACKAGE_OpenGL
        VCPKG_LOCK_FIND_PACKAGE_OpenMP
        VCPKG_LOCK_FIND_PACKAGE_OpenMVG
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
        DensifyPointCloud
        InterfaceCOLMAP
        InterfaceMetashape
        InterfaceMVSNet
        InterfacePolycam
        ReconstructMesh
        RefineMesh
        TextureMesh
        TransformScene
    )
    if("viewer" IN_LIST FEATURES)
        vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES Viewer)
    endif()
    file(INSTALL
            "${SOURCE_PATH}/scripts/python/MvgMvsPipeline.py"
            "${SOURCE_PATH}/scripts/python/MvgOptimizeSfM.py"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
