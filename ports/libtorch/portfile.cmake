vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF v1.8.1
    SHA512 33f5fe813641bdcdcbf5cde4bf8eb5af7fc6f8b3ab37067b0ec10eebda56cdca0c1b42053448ebdd2ab959adb3e9532646324a72729562f8e253229534b39146
    HEAD_REF master
    PATCHES
        fix-cmake-targets.patch
        # todo: Minimize these patches
        # Editing ${SOURCE_PATH}/cmake/Dependencies.cmake makes HORRIBLE readability...
        # Add build option check to deal with targets from other packages
        fix-cmake-dependencies.patch
        # some sources breaks the build ...
        change-foxi-sources.patch
        change-protobuf-sources.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # The file is dummy. We must use generated header files

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    python  BUILD_PYTHON # requires: pybind11, numpy, typing-extensions
    python  USE_NUMPY
    zstd    USE_ZSTD
    fftw3   USE_FFTW
    fftw3   AT_FFTW_ENABLED
    mkl     USE_MKLDNN
    mkl     USE_MKLDNN_CBLAS
    mkl     CAFFE2_USE_MKL
    mkl     CAFFE2_USE_MKLDNN
    mkl     AT_MKL_ENABLED # BLAS=MKL
    mkl     AT_MKLDNN_ENABLED
    eigen3  CAFFE2_USE_EIGEN_FOR_BLAS # BLAS=Eigen
    fbgemm  USE_FBGEMM
    opencv3 USE_OPENCV
    tbb     USE_TBB
    leveldb USE_LEVELDB
    opencl  USE_OPENCL
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_SYSTEM_NCCL
    cuda    USE_NVRTC
    cuda    AT_CUDA_ENABLED
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

if(VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DBLAS=Accelerate) # Accelerate.framework will be used for Apple platforms
elseif("eigen3" IN_LIST FEATURES)
    if("mkl" IN_LIST FEATURES)
        message(FATAL_ERROR "'eigen3' and 'mkl' feature can't be used together")
    endif()
    list(APPEND FEATURE_OPTIONS -DBLAS=Eigen)
elseif("mkl" IN_LIST FEATURES)
    if("mkl" IN_LIST FEATURES)
        message(FATAL_ERROR "'eigen3' and 'mkl' feature can't be used together")
    endif()
    list(APPEND FEATURE_OPTIONS -DBLAS=MKL)
else()
    message(FATAL_ERROR "'eigen3' or 'mkl' feature must be used for BLAS options")
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

vcpkg_find_acquire_program(PYTHON3)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPython3_EXECUTABLE=${PYTHON3}
        -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DBUILD_CUSTOM_PROTOBUF=OFF -DUSE_LITE_PROTO=OFF
        -DBUILD_TEST=OFF -DATEN_NO_TEST=ON
        -DUSE_SYSTEM_LIBS=ON
        -DUSE_NUMA=${VCPKG_TARGET_IS_LINUX} # Linux package `libnuma-dev`
        -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX}
        -DUSE_METAL=${VCPKG_TARGET_IS_OSX}
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
)
vcpkg_cmake_build(TARGET __aten_op_header_gen) # explicit codegen is required
vcpkg_cmake_install()
vcpkg_copy_pdbs()
# todo: combine multiple config.cmake files
vcpkg_cmake_config_fixup(PACKAGE_NAME Caffe2 CONFIG_PATH "share/cmake/Caffe2")

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
