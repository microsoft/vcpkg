vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel-isl/Open3D
    REF v0.18.0
    SHA512 2fe67c0c5447177425fd641a92a0b504d234f38f3f3f3957fc3f58a5681282ef59a57e7f212f20485bbf9c3012455b9e1af2a5861c696c329b4241baf477052f
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_WINDOWS_RUNTIME)

get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_add_to_path(PREPEND "${GIT_PATH}")


vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
        -DWITH_OPENMP=OFF
        -DWITH_FAISS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_GUI=OFF
        -DBUILD_RPC_INTERFACE=OFF
        -DUSE_SYSTEM_EIGEN3=ON
        -DUSE_SYSTEM_FLANN=ON
        -DUSE_SYSTEM_GLEW=ON
        -DUSE_SYSTEM_GLFW=ON
        -DUSE_SYSTEM_JPEG=ON
        -DUSE_SYSTEM_LIBLZF=OFF
        -DUSE_SYSTEM_PNG=OFF
        -DUSE_SYSTEM_TINYGLTF=ON
        -DUSE_SYSTEM_TINYOBJLOADER=ON
        -DUSE_SYSTEM_QHULL=ON
        -DUSE_SYSTEM_FMT=ON
        -DUSE_SYSTEM_PYBIND11=ON
        -DUSE_SYSTEM_GOOGLETEST=ON
        -DUSE_SYSTEM_IMGUI=ON
        -DBUILD_PYTHON_MODULE=OFF
        -DBUILD_LIBREALSENSE=OFF
        -DBUILD_AZURE_KINECT=OFF
        -DBUILD_FILAMENT_FROM_SOURCE=OFF
        -DSTATIC_WINDOWS_RUNTIME=${STATIC_WINDOWS_RUNTIME}
        -DBUILD_CUDA_MODULE=OFF
        -DBUILD_TENSORFLOW_OPS=OFF
        -DGLIBCXX_USE_CXX11_ABI=ON
        -DDEVELOPER_BUILD=OFF
)

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
