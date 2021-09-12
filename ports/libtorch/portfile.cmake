vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF v1.8.1
    SHA512 33f5fe813641bdcdcbf5cde4bf8eb5af7fc6f8b3ab37067b0ec10eebda56cdca0c1b42053448ebdd2ab959adb3e9532646324a72729562f8e253229534b39146
    HEAD_REF master
    PATCHES
        fix-sources.patch
        fix-cmake-targets.patch
        fix-cmake-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    python  BUILD_PYTHON
    python  USE_NUMPY
    zstd    USE_ZSTD
    opencv3 USE_OPENCV
    tbb     USE_TBB
    leveldb USE_LEVELDB
    opencl  USE_OPENCL
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_SYSTEM_NCCL
    cuda    USE_NVRTC
    vulkan  USE_VULKAN
    vulkan  USE_VULKAN_WRAPPER
    vulkan  USE_VULKAN_SHADERC_RUNTIME
    vulkan  USE_VULKAN_RELAXED_PRECISION
    nnpack  USE_NNPACK  # todo: check use of `DISABLE_NNPACK_AND_FAMILY`
    xnnpack USE_XNNPACK
    xnnpack USE_SYSTEM_XNNPACK
    qnnpack USE_QNNPACK # todo: check use of `USE_PYTORCH_QNNPACK`
)

vcpkg_find_acquire_program(PYTHON3)

if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    list(APPEND FEATURE_OPTIONS -DUSE_NATIVE_ARCH=ON)
endif()
if("dist" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_TENSORPIPE=ON)
    endif()
    if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_LIBUV=ON)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_CUSTOM_PROTOBUF=OFF -DUSE_LITE_PROTO=OFF
        -DPython3_EXECUTABLE=${PYTHON3} -DPYTHON_EXECUTABLE=${PYTHON3}
        -DBUILD_TEST=OFF -DATEN_NO_TEST=ON
        -DINTERN_BUILD_MOBILE=OFF
        -DUSE_SYSTEM_LIBS=ON
        -DBUILD_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_NNAPI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_NUMA=${VCPKG_TARGET_IS_LINUX} # Linux package `libnuma-dev`
        -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX}
        -DUSE_METAL=${VCPKG_TARGET_IS_OSX}
        -DBLAS=Eigen
        -DUSE_MKLDNN=OFF
        -DUSE_GFLAGS=ON
        -DUSE_GLOG=ON
        -DUSE_LMDB=ON
        -DUSE_FBGEMM=OFF
        -DUSE_ROCKSDB=OFF
        -DUSE_OPENMP=OFF
        -DUSE_OBSERVERS=OFF 
        -DUSE_PYTORCH_QNNPACK=OFF
        -DUSE_KINETO=OFF
        -DUSE_ROCM=OFF
)
vcpkg_cmake_build(TARGET __aten_op_header_gen) # explicit codegen
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME Torch CONFIG_PATH "share/cmake/Caffe2")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/c10/test/core/impl"
                    "${CURRENT_PACKAGES_DIR}/include/c10/hip"
                    "${CURRENT_PACKAGES_DIR}/include/c10/benchmark"
                    "${CURRENT_PACKAGES_DIR}/include/c10/test"
                    "${CURRENT_PACKAGES_DIR}/include/c10/cuda"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/ideep/operators/quantization"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/python"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/share/contrib/depthwise"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/share/contrib/nnpack"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/mobile"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/experiments/python"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/test"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/utils/hip"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/opt/nql/tests"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/contrib"
                    "${CURRENT_PACKAGES_DIR}/include/caffe2/core/nomnigraph/Representations"
                    "${CURRENT_PACKAGES_DIR}/include/torch/csrc"
)
