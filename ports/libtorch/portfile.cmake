vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF v1.12.1
    SHA512 afeb551904ebd9b5901ae623a98eadbb3045115247cedf8006a940742cfad04e5ce24cfaf363336a9ed88d7ce6a4ac53dbb6a5c690aef6efdf20477c3a22c7ca
    HEAD_REF master
    PATCHES
        pytorch-pr-85958.patch
        fix-cmake.patch
        fix-fbgemm-include.patch
        use-glog-header.patch
        use-flatbuffers2.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # We must use generated header files

find_program(FLATC NAMES flatc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using flatc: ${FLATC}")

vcpkg_execute_required_process(
    COMMAND ${FLATC} --cpp --gen-object-api --gen-mutable mobile_bytecode.fbs
    LOGNAME codegen-flatc-mobile_bytecode
    WORKING_DIRECTORY "${SOURCE_PATH}/torch/csrc/jit/serialization"
)

find_program(PROTOC NAMES protoc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using protoc: ${PROTOC}")


x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PACKAGES typing-extensions pyyaml
    OUT_PYTHON_VAR PYTHON3
)
message(STATUS "Using Python3: ${PYTHON3}")

# Make the configure step use same Python executable
get_filename_component(PYTHON_DIR "${PYTHON3}" PATH)
vcpkg_add_to_path(PREPEND "${PYTHON_DIR}")

# Editing ${SOURCE_PATH}/cmake/Dependencies.cmake makes HORRIBLE readability...
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-dependencies.cmake" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    dist    USE_MPI
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
    list(APPEND FEATURE_OPTIONS -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX})
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
        -DPROTOBUF_PROTOC_EXECUTABLE:FILEPATH="${PROTOC}"
        -DCAFFE2_CUSTOM_PROTOC_EXECUTABLE:FILEPATH="${PROTOC}"
        -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DBUILD_CUSTOM_PROTOBUF=OFF -DUSE_LITE_PROTO=OFF
        -DBUILD_TEST=OFF -DATEN_NO_TEST=ON
        -DUSE_SYSTEM_LIBS=ON
        -DBUILD_PYTHON=OFF
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
        -DUSE_NUMA=OFF
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
vcpkg_cmake_build(TARGET torch_cpu LOGFILE_BASE torch_cpu)
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
