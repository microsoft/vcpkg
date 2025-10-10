vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(GIT_COMMIT e2d141dbde55c2a4370fac5165b0561b6af4798b) # cmake/Codegen.cmake

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF "v${VERSION}"
    SHA512 448e9dad4aa10f1793d35e6ffe9f0f69b7719d41e6eccceb687a8d0c148e22d03e4f76170a05308ef9323a7aea41aa74605077ae1d68c6d949f13b3340ebf310
    HEAD_REF main
    PATCHES
        fix-cmake.patch
        fix-osx.patch
        fix-vulkan.patch # use vulkan-memory-allocator from vcpkg
        fix-glog.patch
        fix-miniz.patch # https://github.com/pytorch/pytorch/commit/a02e88d19c01a7226fa69fa0bf3a6a0b9a21c7e2
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/caffe2/core/macros.h" # We must use generated header files
    "${SOURCE_PATH}/third_party/miniz-3.0.2" # use vcpkg port 'miniz'
)

# even though we are using `USE_KINETO=OFF`, some files are using the headers
# https://github.com/pytorch/kineto/pull/1099 removed MTIA_WORKLOADD enum. use a commit before the change
vcpkg_from_github(
    OUT_SOURCE_PATH src_kineto
    REPO pytorch/kineto
    REF 3f4beb08ad7e49be28eafa1216233df73e5be06f # 2025-06-03
    SHA512 742e5119e130d3a01bf92480af9285c93663126b22de2c597fa566fb571969a724bb225ddb122e1cb32bce13d6507f6d3e8500205d0d6811f9c67838f44828ef
    HEAD_REF main
)
file(COPY "${src_kineto}/" DESTINATION "${SOURCE_PATH}/third_party/kineto")

vcpkg_from_github(
    OUT_SOURCE_PATH src_cudnn
    REPO NVIDIA/cudnn-frontend
    REF "v1.14.0"
    SHA512 95dbf57594eda08905f176f6f18be297cfbac571460829c55959f15e87f92e9019812ff367bf857dc26d6961d9c6393e667b09e855732e3ab7645e93f325efa1
    HEAD_REF main
)
file(COPY "${src_cudnn}/" DESTINATION "${SOURCE_PATH}/third_party/cudnn_frontend")


file(REMOVE
  "${SOURCE_PATH}/cmake/Modules/FindBLAS.cmake"
  "${SOURCE_PATH}/cmake/Modules/FindLAPACK.cmake"
  "${SOURCE_PATH}/cmake/Modules/FindCUDA.cmake"
  "${SOURCE_PATH}/cmake/Modules/FindCUDAToolkit.cmake"
  "${SOURCE_PATH}/cmake/Modules/Findpybind11.cmake"
)

find_program(FLATC NAMES flatc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using flatc: ${FLATC}")

vcpkg_execute_required_process(
    COMMAND ${FLATC} --cpp --no-prefix --scoped-enums --gen-mutable mobile_bytecode.fbs
    LOGNAME codegen-flatc-mobile_bytecode
    WORKING_DIRECTORY "${SOURCE_PATH}/torch/csrc/jit/serialization"
)

find_program(PROTOC NAMES protoc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using protoc: ${PROTOC}")

x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PACKAGES typing-extensions pyyaml numpy
    OUT_PYTHON_VAR PYTHON3
)

message(STATUS "Using Python3: ${PYTHON3}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    fbgemm  USE_FBGEMM
    openmp  USE_OPENMP
    opencl  USE_OPENCL
    mkldnn  USE_MKLDNN
    mkldnn  USE_MKLDNN_CBLAS
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_NVRTC
    cuda    USE_MAGMA
    vulkan  USE_VULKAN
    vulkan  USE_VULKAN_RELAXED_PRECISION
    llvm    USE_LLVM
    mpi     USE_MPI
    nnpack  USE_NNPACK  # todo: check use of `DISABLE_NNPACK_AND_FAMILY`
#   No feature in vcpkg yet so disabled. -> Requires numpy build by vcpkg itself
    python  BUILD_PYTHON
    python  USE_NUMPY
    glog    USE_GLOG
    gflags  USE_GFLAGS
)

if("dist" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_TENSORPIPE=ON)
    endif()
    if(VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_LIBUV=ON)
    endif()
    list(APPEND FEATURE_OPTIONS -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX})
endif()

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root) 
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}" 
    )
endif()

if("vulkan" IN_LIST FEATURES) # Vulkan::glslc in FindVulkan.cmake
    find_program(GLSLC NAMES glslc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/shaderc" REQUIRED)
    message(STATUS "Using glslc: ${GLSLC}")
    list(APPEND FEATURE_OPTIONS "-DVulkan_GLSLC_EXECUTABLE:FILEPATH=${GLSLC}")
endif()

set(TARGET_IS_MOBILE OFF)
if(VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS)
    set(TARGET_IS_MOBILE ON)
endif()

# By default MKL is used. We will use Eigen 
set(BLAS "Eigen")
if(TARGET_IS_MOBILE)
    # In mobile, Eigen(embedded source) is used. We will use OpenBLAS instead.
    set(BLAS "OpenBLAS") # see how port 'blas' works
endif()

set(TARGET_IS_APPLE OFF)
if(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX)
    set(TARGET_IS_APPLE ON)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPROTOBUF_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}"
        "-DCAFFE2_CUSTOM_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}"
        "-DPython_EXECUTABLE:FILEPATH=${PYTHON3}" # cmake/Codegen.cmake
        -DBUILD_CUSTOM_PROTOBUF=OFF # cmake/ProtoBuf.cmake
        -DCOMMIT_SHA=${GIT_COMMIT} # cmake/Codegen.cmake
        -DINTERN_BUILD_MOBILE=${TARGET_IS_MOBILE}
        -DATEN_NO_TEST=ON
        -DCAFFE2_STATIC_LINK_CUDA=ON
        -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DCAFFE2_CMAKE_BUILDING_WITH_MAIN_REPO=OFF
        -DUSE_FLASH_ATTENTION=OFF
        -DUSE_ITT=OFF
        -DUSE_KINETO=OFF
        -DUSE_ROCM=OFF # This is an alternative to cuda
        -DUSE_NUMA=${VCPKG_TARGET_IS_LINUX}
        -DUSE_SYSTEM_LIBS=ON
        -DBUILD_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_NNAPI=${VCPKG_TARGET_IS_ANDROID}
        -DBLAS=${BLAS} # BLAS=MKL not supported in this port
        -DUSE_COREML_DELEGATE=${VCPKG_TARGET_IS_IOS}
        -DUSE_PYTORCH_METAL=${TARGET_IS_APPLE}
        -DUSE_PYTORCH_METAL_EXPORT=${VCPKG_TARGET_IS_OSX}
        -DUSE_PYTORCH_QNNPACK=OFF
    OPTIONS_DEBUG
        -DPRINT_CMAKE_DEBUG_INFO=ON
    MAYBE_UNUSED_VARIABLES
        USE_NUMA
        MKLDNN_CPU_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME Caffe2 CONFIG_PATH "share/cmake/Caffe2" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME Torch CONFIG_PATH "share/cmake/Torch" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME ATen CONFIG_PATH "share/cmake/ATen" )

# Traverse the folder and remove "some" empty folders
function(cleanup_once folder)
    if(NOT IS_DIRECTORY "${folder}")
        return()
    endif()
    file(GLOB paths LIST_DIRECTORIES true "${folder}/*")
    list(LENGTH paths count)
    # 1. remove if the given folder is empty
    if(count EQUAL 0)
        file(REMOVE_RECURSE "${folder}")
        message(STATUS "Removed ${folder}")
        return()
    endif()
    # 2. repeat the operation for hop 1 sub-directories 
    foreach(path ${paths})
        cleanup_once(${path})
    endforeach()
endfunction()

# Some folders may contain empty folders. They will become empty after `cleanup_once`.
# Repeat given times to delete new empty folders.
function(cleanup_repeat folder repeat)
    if(NOT IS_DIRECTORY "${folder}")
        return()
    endif()
    while(repeat GREATER_EQUAL 1)
        math(EXPR repeat "${repeat} - 1" OUTPUT_FORMAT DECIMAL)
        cleanup_once("${folder}")
    endwhile()
endfunction()

cleanup_repeat("${CURRENT_PACKAGES_DIR}/include" 5)
cleanup_repeat("${CURRENT_PACKAGES_DIR}/lib/site-packages" 13)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled) # torch_global_deps.dll is empty.c and just for linking deps

