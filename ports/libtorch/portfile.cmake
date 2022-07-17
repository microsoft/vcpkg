vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF v1.10.0
    SHA512 92b70e6170a7f173c4a9cb29f6cec6dfa598587aa9cf6a620ec861b95da6ea555cbc7285914c0dab6cfc8af320fad4999be4a788acc1f15140664a67ad9dc35d
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        fix-sources.patch
        use-glog-header.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # We must use generated header files

x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PACKAGES typing-extension pyyaml
    OUT_PYTHON_VAR PYTHON3
)

# Editing ${SOURCE_PATH}/cmake/Dependencies.cmake makes HORRIBLE readability...
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-dependencies.cmake" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    zstd    USE_ZSTD
    fftw3   USE_FFTW
    fftw3   AT_FFTW_ENABLED
    fbgemm  USE_FBGEMM
    opencv  USE_OPENCV
    tbb     USE_TBB
    leveldb USE_LEVELDB
    opencl  USE_OPENCL
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_SYSTEM_NCCL
    cuda    USE_NVRTC
    cuda    AT_CUDA_ENABLED
    cuda    AT_CUDNN_ENABLED
    vulkan  USE_VULKAN
    vulkan  USE_VULKAN_WRAPPER
    vulkan  USE_VULKAN_SHADERC_RUNTIME
    vulkan  USE_VULKAN_RELAXED_PRECISION
    nnpack  USE_NNPACK  # todo: check use of `DISABLE_NNPACK_AND_FAMILY`
    nnpack  AT_NNPACK_ENABLED
    xnnpack USE_XNNPACK
    xnnpack USE_SYSTEM_XNNPACK
    qnnpack USE_QNNPACK # todo: check use of `USE_PYTORCH_QNNPACK`
)

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

if(VCPKG_TARGET_IS_LINUX)
    # Linux package `libnuma-dev`
    find_library(Numa_LIBPATH NAMES numa PATHS "/usr/lib" "/usr/lib/x86_64-linux-gnu")
    if(Numa_LIBPATH)
        message(STATUS "Detected numa: ${Numa_LIBPATH}")
        list(APPEND FEATURE_OPTIONS -DUSE_NUMA=ON)
    else()
        message(STATUS "To enable USE_NUMA build option, install 'libnuma-dev' package")
        list(APPEND FEATURE_OPTIONS -DUSE_NUMA=OFF)
    endif()
else()
    list(APPEND FEATURE_OPTIONS -DUSE_NUMA=OFF)
endif()

if(VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DBLAS=Accelerate) # Accelerate.framework will be used for Apple platforms
else()
    list(APPEND FEATURE_OPTIONS -DBLAS=Eigen)
endif()

if("tbb" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS
        -DMKLDNN_CPU_RUNTIME=TBB
    )
endif()

if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND FEATURE_OPTIONS
        -DINTERN_BUILD_MOBILE=ON
        -DBUILD_JNI=ON
        -DUSE_NNAPI=ON
    )
else()
    list(APPEND FEATURE_OPTIONS -DINTERN_BUILD_MOBILE=OFF)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DBUILD_CUSTOM_PROTOBUF=OFF -DUSE_LITE_PROTO=OFF
        -DBUILD_TEST=OFF -DATEN_NO_TEST=ON
        -DUSE_SYSTEM_LIBS=ON
        -DBUILD_PYTHON=OFF
        -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX}
        -DUSE_MPI=${VCPKG_TARGET_IS_LINUX} # Linux package `libopenmpi-dev`
        -DUSE_METAL=OFF
        -DUSE_PYTORCH_METAL=OFF
        -DUSE_PYTORCH_METAL_EXPORT=OFF
        -DUSE_BLAS=ON # Eigen, MKL, or Accelerate
        -DUSE_GFLAGS=ON
        -DUSE_GLOG=ON
        -DUSE_LMDB=ON
        -DUSE_ROCKSDB=OFF
        -DUSE_OPENMP=OFF
        -DUSE_OBSERVERS=OFF 
        -DUSE_PYTORCH_QNNPACK=OFF
        -DUSE_KINETO=OFF
        -DUSE_ROCM=OFF
        -DUSE_DEPLOY=OFF
        -DUSE_BREAKPAD=OFF
        -DUSE_FFTW=OFF
        -DCAFFE2_USE_EIGEN_FOR_BLAS=ON
        # BLAS=MKL not supported
        -DUSE_MKLDNN=OFF
        -DUSE_MKLDNN_CBLAS=OFF
        -DCAFFE2_USE_MKL=OFF
        -DCAFFE2_USE_MKLDNN=OFF
        -DAT_MKL_ENABLED=OFF
        -DAT_MKLDNN_ENABLED=OFF
    OPTIONS_RELEASE
        -DBUILD_LIBTORCH_CPU_WITH_DEBUG=ON
    MAYBE_UNUSED_VARIABLES
        USE_NUMA
        USE_SYSTEM_BIND11
        USE_VULKAN_WRAPPER
        MKLDNN_CPU_RUNTIME
)
vcpkg_cmake_build(TARGET __aten_op_header_gen) # explicit codegen is required
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/share"
                    "${CURRENT_PACKAGES_DIR}/include/c10/test/core/impl"
                    "${CURRENT_PACKAGES_DIR}/include/c10/hip"
                    "${CURRENT_PACKAGES_DIR}/include/c10/benchmark"
                    "${CURRENT_PACKAGES_DIR}/include/c10/test"
                    "${CURRENT_PACKAGES_DIR}/include/c10/cuda"
                    "${CURRENT_PACKAGES_DIR}/include/c10d/quantization"
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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
