vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(GIT_COMMIT e2d141dbde55c2a4370fac5165b0561b6af4798b) # cmake/Codegen.cmake

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF "v${VERSION}"
    SHA512 a9fc2252af9031c2cd46dde558c491aea8bc322fb80157a7760f300a44b759d4bfe866f030fbb974b80493057cfff4dd512498f99a100ed6d05bf620258ed37e
    HEAD_REF main
    PATCHES
        fix-pytorch-pr-156630.patch # https://github.com/pytorch/pytorch/pull/156630
        fix-cmake.patch
        fix-glog.patch
        fix-kineto.patch
        fix-vulkan.patch
        fix-miniz.patch
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/caffe2/core/macros.h" # We must use generated header files
    "${SOURCE_PATH}/third_party/miniz-3.0.2" # use vcpkg port 'miniz'
)

# even though we are using `USE_KINETO=OFF`, some files are using the headers
vcpkg_from_github(
    OUT_SOURCE_PATH src_kineto
    REPO pytorch/kineto
    REF 54ffcd4fb0bd77a5ecea46d11b4ed12d393c7fe3 # 2025-07-17
    SHA512 5346f9d97e12ac200b5d9d5e96fa6c6b9e4b84736d0beea51050725949f6fca31af020aff287468426c2b04588428fc67fbb1c8eb1f50fbef2f5e6ad002c58de
    HEAD_REF main
)
file(COPY "${src_kineto}/" DESTINATION "${SOURCE_PATH}/third_party/kineto")

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
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_NVRTC
    cuda    USE_MAGMA
    vulkan  USE_VULKAN
    vulkan  USE_VULKAN_RELAXED_PRECISION
    rocm    USE_ROCM  # This is an alternative to cuda not a feature! (Not in vcpkg.json!) -> disabled
    llvm    USE_LLVM
    mpi     USE_MPI
    nnpack  USE_NNPACK  # todo: check use of `DISABLE_NNPACK_AND_FAMILY`
#   No feature in vcpkg yet so disabled. -> Requires numpy build by vcpkg itself
    python  BUILD_PYTHON
    python  USE_NUMPY
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
    message(STATUS "Using nvcc: ${NVCC}")
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER:FILEPATH=${NVCC}"
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
        -DBUILD_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_GFLAGS=ON
        -DUSE_GLOG=ON
        -DUSE_ITT=OFF
        -DUSE_OBSERVERS=OFF
        -DUSE_ROCM=OFF
        -DUSE_NUMA=${VCPKG_TARGET_IS_LINUX}
        -DUSE_NNAPI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_MKLDNN=OFF
        -DUSE_MKLDNN_CBLAS=OFF
        -DUSE_KINETO=OFF
        -DUSE_COREML_DELEGATE=${VCPKG_TARGET_IS_IOS}
        -DUSE_PYTORCH_METAL=${TARGET_IS_APPLE}
        -DUSE_PYTORCH_METAL_EXPORT=${VCPKG_TARGET_IS_OSX}
        -DUSE_PYTORCH_QNNPACK=OFF
        -DUSE_SYSTEM_LIBS=ON
    OPTIONS_DEBUG
        -DPRINT_CMAKE_DEBUG_INFO=ON
    MAYBE_UNUSED_VARIABLES
        USE_NUMA
        MKLDNN_CPU_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME Caffe2 CONFIG_PATH "share/cmake/Caffe2" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME Torch CONFIG_PATH "share/cmake/Torch")

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
