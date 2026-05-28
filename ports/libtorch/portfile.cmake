vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF "v${VERSION}"
    SHA512 f5ab0f6933d88271f772b416f8c9b3b0d3e1ffaf8d00838b455206266b40d7c805e34003d84b01cddc7f1ad917dd72d6f79a05063b0962cbf223d9042cff3206
    HEAD_REF master
    PATCHES
        fix-osx-protobuf.patch
        fix-vulkan-vma.patch
        fix-system-mimalloc.patch
        fix-system-fp16.patch
        fix-system-tensorpipe.patch
        fix-system-fmt.patch
        fix-system-fxdiv.patch
        fix-system-kineto.patch
        fix-torch-includes.patch
        fix-glog.patch
        fix-system-flatbuffers.patch
        fix-system-httplib.patch
        fix-system-nlohmann.patch
        fix-system-pthreadpool.patch
        fix-system-cpuinfo.patch
        fix-system-xnnpack.patch
        fix-system-onnx.patch
        fix-system-cutlass.patch
        fix-system-fbgemm.patch
        fix-system-nnpack.patch
        fix-sleef.patch
        fix-cudnn-frontend.patch
        )

file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # We must use generated header files

# cmake/Dependencies.cmake hardcodes third_party/pocketfft — copy the vcpkg header there
file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/pocketfft")
file(COPY "${CURRENT_INSTALLED_DIR}/include/pocketfft_hdronly.h"
     DESTINATION "${SOURCE_PATH}/third_party/pocketfft/")


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
    PACKAGES typing-extensions pyyaml packaging setuptools
    # numpy
    OUT_PYTHON_VAR PYTHON3
)

message(STATUS "Using Python3: ${PYTHON3}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    fbgemm  USE_FBGEMM
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_SYSTEM_NCCL
    cuda    USE_NVRTC
    cuda    AT_CUDA_ENABLED
    cuda    USE_MAGMA
    vulkan  USE_VULKAN        # cmake_dependent_option forces OFF on non-Android; kept for future
    vulkan  USE_VULKAN_RELAXED_PRECISION
    rocm    USE_ROCM  # alternative to cuda, not a vcpkg feature; always disabled
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
        -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}
        -DCAFFE2_CUSTOM_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}
        -DPython_EXECUTABLE:FILEPATH=${PYTHON3}
        -DPython3_EXECUTABLE:FILEPATH=${PYTHON3}
        -DBUILD_PYTHON=OFF
        -DUSE_NUMPY=OFF
        -DCAFFE2_STATIC_LINK_CUDA=ON
        -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DBUILD_CUSTOM_PROTOBUF=OFF
        -DUSE_LITE_PROTO=OFF
        -DBUILD_TEST=OFF
        -DATEN_NO_TEST=ON
        -DUSE_SYSTEM_LIBS=ON
        -DUSE_FLASH_ATTENTION=OFF
        -DUSE_MEM_EFF_ATTENTION=OFF
        -DUSE_XPU=OFF
        -DUSE_XCCL=OFF
        -DUSE_PYTORCH_METAL=OFF
        -DUSE_PYTORCH_METAL_EXPORT=OFF
        -DUSE_PYTORCH_QNNPACK:BOOL=OFF
        -DUSE_ITT=OFF
        -DUSE_OBSERVERS=OFF
        -DUSE_KINETO=OFF
        -DUSE_ROCM=OFF
        -DUSE_NUMA=OFF
        -DBUILD_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_NNAPI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_MKLDNN=OFF         # no mkldnn feature; hardcoded off
        -DUSE_MKLDNN_CBLAS=OFF
        -DAT_MKLDNN_ENABLED=OFF
        -DUSE_OPENCL=ON          # opencl is a base dep, always on
        -DCUDNN_FRONTEND_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
    MAYBE_UNUSED_VARIABLES
        USE_NUMA    # cmake_dependent_option forces OFF on non-Linux
        USE_VULKAN  # cmake_dependent_option forces OFF on non-Android
)

# cmake_install.cmake has an install rule for FindCUDAToolkit.cmake but we deleted
# it before configure so cmake would use its own up-to-date version. Restore a stub
# so cmake --install doesn't error out trying to install the now-missing file.
file(WRITE "${SOURCE_PATH}/cmake/Modules/FindCUDAToolkit.cmake"
    "# placeholder: original removed pre-configure so cmake uses its own FindCUDAToolkit\n")

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME Caffe2 CONFIG_PATH "share/cmake/Caffe2" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME torch CONFIG_PATH "share/cmake/Torch" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME ATen CONFIG_PATH "share/cmake/ATen" )

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/torch/TorchConfig.cmake" "/../../../" "/../../")

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

