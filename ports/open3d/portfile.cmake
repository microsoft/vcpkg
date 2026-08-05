string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPEN3D_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" OPEN3D_STATIC_WINDOWS_RUNTIME)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda BUILD_CUDA_MODULE
)

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isl-org/Open3D
    REF df18cd291b996035267672d4fbf847095d057f4a
    SHA512 c26eee0623f235f1d96056c1d106476a72d6191a6a13affdfea22a3824a3ffc19f9cfda84bb78df80c0541535783fe99d2e8c1a0671e131fe893920b54533e4a
    HEAD_REF main
    PATCHES
        disable-tools-apps.patch
        fix-cuda-fmt.patch
        fix-cuda-msvc-preprocessor.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_SHARED_LIBS=${OPEN3D_BUILD_SHARED}
        -DOPEN3D_USE_VCPKG=ON
        -DBUILD_TOOLS=OFF
        -DBUILD_APPS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_PYTHON_MODULE=OFF
        -DWITH_STUBGEN=OFF
        -DBUILD_GUI=OFF
        -DBUILD_WEBRTC=OFF
        -DBUILD_JUPYTER_EXTENSION=OFF
        -DBUILD_ISPC_MODULE=OFF
        -DWITH_IPP=OFF
        -DWITH_MINIZIP=ON
        -DBUILD_LIBREALSENSE=OFF
        -DBUILD_AZURE_KINECT=OFF
        -DBUILD_TENSORFLOW_OPS=OFF
        -DBUILD_PYTORCH_OPS=OFF
        -DBUNDLE_OPEN3D_ML=OFF
        -DBUILD_VTK_FROM_SOURCE=OFF
        -DUSE_SYSTEM_VTK=ON
        -DDEVELOPER_BUILD=OFF
        -DSTATIC_WINDOWS_RUNTIME=${OPEN3D_STATIC_WINDOWS_RUNTIME}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Open3D)
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/open3d/data/dataset"
    "${CURRENT_PACKAGES_DIR}/include/open3d/io/file_format"
    "${CURRENT_PACKAGES_DIR}/include/open3d/ml/tensorflow/tf_subsampling"
    "${CURRENT_PACKAGES_DIR}/include/open3d/t/io/file_format"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/gui/Materials"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/gui/Resources"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/rendering/gaussian_splat/shaders"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/shader/glsl"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/webrtc_server/html"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
