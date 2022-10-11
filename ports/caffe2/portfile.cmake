vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caffe2/caffe2
    REF eab13a2d5c807bf5d49efd4584787b639a981b79
    SHA512 505a8540b0c28329c4e2ce443ac8e198c1ee613eb6b932927ee9d04c8afdc95081f3c4581408b7097d567840427b31f6d7626ea80f27e56532f2f2e6acd87023
    HEAD_REF master
    PATCHES
        msvc-fixes.patch
        fix-space.patch
        fix-protobuf-deprecated.patch
        no-inout-macros.patch
        fix-isgloginitialized.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(USE_STATIC_RUNTIME ON)
else()
    set(USE_STATIC_RUNTIME OFF)
endif()

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    # Set to ON to use python
    -DBUILD_PYTHON=OFF
    -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
    -DUSE_GFLAGS=ON
    -DUSE_GLOG=ON
    # Cannot use OpenCV without USE_CUDA=ON right now
    -DUSE_OPENCV=OFF
    -DUSE_THREADS=ON
    # Uncomment to use MKL
    # -DBLAS=MKL
    -DUSE_CUDA=OFF
    -DUSE_FFMPEG=OFF
    -DUSE_GLOO=OFF
    -DUSE_LEVELDB=OFF
    -DUSE_LITE_PROTO=OFF
    -DUSE_METAL=OFF
    -DUSE_MOBILE_OPENGL=OFF
    -DUSE_MPI=OFF
    -DUSE_NCCL=OFF
    -DUSE_NERVANA_GPU=OFF
    -DUSE_NNPACK=OFF
    -DUSE_OBSERVERS=OFF
    -DUSE_OPENMP=ON
    -DUSE_REDIS=OFF
    -DUSE_ROCKSDB=OFF
    -DUSE_SNPE=OFF
    -DUSE_ZMQ=OFF
    -DBUILD_TEST=OFF
    -DPROTOBUF_PROTOC_EXECUTABLE:FILEPATH=${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc${EXECUTABLE_SUFFIX}
)

vcpkg_cmake_install()

# Remove folders from install
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/caffe")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/caffe2")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/caffe")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/caffe2")

# Remove empty directories from include (should probably fix or
# patch caffe2 install script)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/test")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/python")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/experiments/python")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/opengl")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/nnpack")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/libopencl-stub")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/docker-ubuntu-14.04")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caffe2/binaries")

# Move bin to tools
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(GLOB BINARIES "${CURRENT_PACKAGES_DIR}/bin/*${EXECUTABLE_SUFFIX}")
foreach(binary IN LISTS BINARIES)
    get_filename_component(binary_name ${binary} NAME)
    file(RENAME ${binary} "${CURRENT_PACKAGES_DIR}/tools/${binary_name}")
endforeach()

# Remove bin directory
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Remove headers and tools from debug build
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# install license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
