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
        fix-system-kleidiai.patch
        fix-system-mkl.patch
        fix-system-mkldnn.patch
        fix-system-pocketfft.patch
        fix-sleef.patch
        fix-cudnn-frontend.patch
        fix-windows-install-dirs.patch
        fix-async-mm-cutlass.patch
        )

file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # We must use generated header files

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
    dist    USE_DISTRIBUTED # Gloo, MPI, TensorPipe
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
#   No feature in vcpkg yet so disabled. -> Requires numpy build by vcpkg itself
    python  BUILD_PYTHON
    python  USE_NUMPY
    glog    USE_GLOG
    gflags  USE_GFLAGS
)

# FBGEMM and NNPACK are ON by default in upstream PyTorch, so they are core (not
# optional features). Enable each wherever its vcpkg dependency is available for
# the target arch; the matching core dependency in vcpkg.json is platform-gated.
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND FEATURE_OPTIONS -DUSE_FBGEMM=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_FBGEMM=OFF)
endif()
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DUSE_NNPACK=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_NNPACK=OFF)
endif()

if("dist" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_TENSORPIPE=ON)
    endif()
    if(VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_LIBUV=ON)
    endif()
    list(APPEND FEATURE_OPTIONS -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX})
    # MPI was folded into [dist]; the mpi dependency is linux-only (see vcpkg.json).
    list(APPEND FEATURE_OPTIONS -DUSE_MPI=${VCPKG_TARGET_IS_LINUX})
endif()

if("cuda" IN_LIST FEATURES)
  vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    # PyTorch's default TORCH_CUDA_ARCH_LIST still includes Maxwell (5.0). CUDA 13
    # dropped Maxwell/Pascal/Volta (sm_50/60/70), so nvcc aborts with
    # "Unsupported gpu architecture 'compute_50'". Pin to Turing->Hopper.
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
        "-DTORCH_CUDA_ARCH_LIST=7.5;8.0;8.6;8.9;9.0"
    )
endif()

if("vulkan" IN_LIST FEATURES) # Vulkan::glslc in FindVulkan.cmake
    find_program(GLSLC NAMES glslc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/shaderc" REQUIRED)
    message(STATUS "Using glslc: ${GLSLC}")
    # Vulkan_GLSLC_EXECUTABLE is the variable FindVulkan honours; GLSLC_PATH is the
    # one cmake/VulkanCodegen.cmake does its own find_program for, which under
    # cross-compile (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM=ONLY) won't see host tools.
    # Set both so the codegen step accepts the host glslc binary.
    list(APPEND FEATURE_OPTIONS
        "-DVulkan_GLSLC_EXECUTABLE:FILEPATH=${GLSLC}"
        "-DGLSLC_PATH:FILEPATH=${GLSLC}")
endif()

if("mkl" IN_LIST FEATURES)
    # The mkl feature is the "Intel performance" bundle: it routes PyTorch's BLAS
    # chooser at cmake/Dependencies.cmake through the MKL branch, which calls
    # find_package(MKL) -> our replacement FindMKL.cmake -> vcpkg intel-mkl, and it
    # also turns on oneDNN (MKLDNN) via ideep. VCPKG_LIBTORCH_MKL_FEATURE_ENABLED
    # gates the FindMKL replacement: when the feature is off, the replacement
    # returns MKL_FOUND=FALSE without calling find_package, so a transitively-staged
    # intel-mkl can't silently turn on BLAS=MKL with ILP64 defaults and trip vml.h's
    # `is_same_v<MKL_INT, int64_t>`.
    list(APPEND FEATURE_OPTIONS
        -DBLAS=MKL
        -DVCPKG_LIBTORCH_MKL_FEATURE_ENABLED=ON
        -DUSE_MKLDNN=ON
        -DAT_MKLDNN_ENABLED=ON)
else()
    # oneDNN/ideep are only pulled in by [mkl]; without the feature, force MKLDNN
    # off so PyTorch's default-ON USE_MKLDNN doesn't look for an absent dependency.
    list(APPEND FEATURE_OPTIONS -DUSE_MKLDNN=OFF)
endif()

# Always force LP64. Even when libtorch[mkl] is off, mkldnn / fbgemm and other
# subprojects can independently call find_package(MKL CONFIG); without this they
# default to ILP64 and PyTorch's vml.h static_assert fails on Linux x86_64
# (int64_t = long, but ILP64 MKL_INT = long long — same width, distinct types).
list(APPEND FEATURE_OPTIONS -DMKL_INTERFACE=lp64)

if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    # Upstream auto-enables USE_PRIORITIZED_TEXT_FOR_LD on Linux+AArch64
    # (CMakeLists.txt:408-410), which runs tools/setup_helpers/generate_linker_script.py.
    # That script calls $LD -verbose to capture the default linker script — but on
    # vcpkg cross-compile CI hosts $LD is the x86-64 ld, producing a script with
    # OUTPUT_FORMAT(elf64-x86-64). The aarch64 cross-linker then rejects it with
    # "cannot represent machine i386:x86-64". Disable the optimization here.
    list(APPEND FEATURE_OPTIONS -DUSE_PRIORITIZED_TEXT_FOR_LD=OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    # PyTorch ends up reporting "USE_XNNPACK: OFF" on x86-windows anyway (some
    # later guard flips it), but fix-system-xnnpack.patch fires at Dependencies.cmake:530
    # while USE_XNNPACK is still ON and appends XNNPACK + microkernels-prod to
    # Caffe2_DEPENDENCY_LIBS. That list never gets cleaned up, and the x86-windows
    # imported targets fail the generate-time IMPORTED_IMPLIB check (x64-windows
    # tolerates the same shape). Force the option off from the start so our patch
    # branch is skipped entirely.
    list(APPEND FEATURE_OPTIONS -DUSE_XNNPACK=OFF)
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
        -DUSE_MKLDNN_CBLAS=OFF   # the CBLAS-via-MKLDNN sub-path stays off
        -DUSE_OPENCL=ON          # opencl is a base dep, always on
        -DCUDNN_FRONTEND_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
    MAYBE_UNUSED_VARIABLES
        CUDNN_FRONTEND_INCLUDE_DIR
        MKL_INTERFACE
        USE_NUMA    # cmake_dependent_option forces OFF on non-Linux
        USE_VULKAN  # cmake_dependent_option forces OFF on non-Android
        VCPKG_LIBTORCH_MKL_FEATURE_ENABLED  # consumed by patched FindMKL.cmake, not the top-level CMakeLists
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

