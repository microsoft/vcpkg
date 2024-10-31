vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel-isl/Open3D
    REF v0.18.0
    SHA512 2fe67c0c5447177425fd641a92a0b504d234f38f3f3f3957fc3f58a5681282ef59a57e7f212f20485bbf9c3012455b9e1af2a5861c696c329b4241baf477052f
    HEAD_REF master
    PATCHES
        0001-uvatlas.patch
        0002-blas.patch
        0003-liblzf.patch
        0004-tiny_gltf.patch
        0005-jsoncpp.patch
        0007-parallelstl.patch
        0008-curl.patch
        0009-std-includes.patch
        0010-imgui.patch
        0011-llvm.patch
        0012-webrtc.patch
        # remove in the next release
        6783.patch
        6969.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_WINDOWS_RUNTIME)

get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_add_to_path(PREPEND "${GIT_PATH}")


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "gui"            BUILD_GUI
        "blas"           USE_BLAS
        "intel-oneapi"   OPEN3D_USE_ONEAPI_PACKAGES
        "sycl"           BUILD_SYCL_MODULE
        "openmp"         WITH_OPENMP
        "python"         BUILD_PYTHON_MODULE
        "azure-kinect"   BUILD_AZURE_KINECT
        "realsense2"     BUILD_LIBREALSENSE
)

if(BUILD_GUI)
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID OR VCPKG_HOST_IS_FREEBSD OR VCPKG_HOST_IS_OPENBSD)
        message(WARNING "open3d with gui feature requires the following packages via the system package manager:
  libc++ libc++abi
On Debian/Ubuntu derivatives:
  sudo apt-get install libc++-dev libc++abi-dev")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
        -DSTATIC_WINDOWS_RUNTIME=${STATIC_WINDOWS_RUNTIME}
        -DDEVELOPER_BUILD=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_GUI=${BUILD_GUI}
        -DBUILD_ISPC_MODULE=OFF
        -DBUILD_CUDA_MODULE=OFF
        -DBUILD_TENSORFLOW_OPS=OFF
        -DBUILD_PYTHON_MODULE=${BUILD_PYTHON_MODULE}
        -DBUILD_LIBREALSENSE=${BUILD_LIBREALSENSE}
        -DBUILD_AZURE_KINECT=${BUILD_AZURE_KINECT}
        -DBUILD_SYCL_MODULE=${BUILD_SYCL_MODULE}
        -DOPEN3D_USE_ONEAPI_PACKAGES=${OPEN3D_USE_ONEAPI_PACKAGES}
        -DUSE_BLAS=${USE_BLAS}
        -DUSE_SYSTEM_BLAS=ON
        -DWITH_OPENMP=${WITH_OPENMP}
        -DUSE_SYSTEM_ASSIMP=ON
        -DUSE_SYSTEM_CURL=ON
        -DUSE_SYSTEM_CUTLASS=ON
        -DUSE_SYSTEM_EIGEN3=ON
        -DUSE_SYSTEM_EMBREE=ON
        -DUSE_SYSTEM_FILAMENT=ON
        -DUSE_SYSTEM_FMT=ON
        -DUSE_SYSTEM_GLEW=ON
        -DUSE_SYSTEM_GLFW=ON
        -DUSE_SYSTEM_GOOGLETEST=ON
        -DUSE_SYSTEM_IMGUI=ON
        -DUSE_SYSTEM_JPEG=ON
        -DUSE_SYSTEM_JSONCPP=ON
        -DUSE_SYSTEM_LIBLZF=ON
        -DUSE_SYSTEM_MSGPACK=ON
        -DUSE_SYSTEM_NANOFLANN=ON
        -DUSE_SYSTEM_OPENSSL=ON
        -DUSE_SYSTEM_PNG=ON
        -DUSE_SYSTEM_PYBIND11=ON
        -DUSE_SYSTEM_QHULLCPP=ON
        -DUSE_SYSTEM_STDGPU=ON
        -DUSE_SYSTEM_TBB=ON
        -DUSE_SYSTEM_TINYGLTF=ON
        -DUSE_SYSTEM_TINYOBJLOADER=ON
        -DUSE_SYSTEM_UVATLAS=ON
        -DUSE_SYSTEM_VTK=ON
        -DUSE_SYSTEM_ZEROMQ=ON
        -DUSE_SYSTEM_PARALLELSTL=ON
        -DWITH_MINIZIP=ON
)

vcpkg_cmake_build(TARGET Open3D)
vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Open3D)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/t/io/file_format")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/ml/tensorflow/tf_neighbors")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/ml/tensorflow/tf_subsampling")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/gui/Resources")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/gui/Materials")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/shader/glsl")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/webrtc_server/html")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/open3d/io/file_format")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
