vcpkg_download_distfile(
    CUDNN_9_FIX
    URLS https://github.com/pytorch/pytorch/commit/e14026bc2a6cd80bedffead77a5d7b75a37f8e67.patch?full_index=1
    SHA512 9569547b44b61f9559f0e7ab91f2be51657ece4f5462b6860cb5eae8d23d01187d6af046b369a77a228fe4d7153f5c683b686e84c1296a662f83e5f1f281bc7e
    FILENAME libtorch-cudnn-9-fix-e14026bc2a6cd80bedffead77a5d7b75a37f8e67.patch
)

vcpkg_download_distfile(
    CUDA_THRUST_MISSING_HEADER_FIX
    URLS https://github.com/pytorch/pytorch/commit/2a440348958b3f0a2b09458bd76fe5959b371c0c.patch?full_index=1
    SHA512 eff10d81b1c635108ad1b95a430865a76ab3f2079be74e61e06876942ac1fd43a274fc1c73e43c2c01b9ce5aca648213ef75c13c28b8ffa40497e4e26d5e3b16
    FILENAME libtorch-cuda-thrust-missing-header-2a440348958b3f0a2b09458bd76fe5959b371c0c.patch
)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF "v${VERSION}"
    SHA512 a8961d78ad785b13c959a0612563a60e0de17a7c8bb9822ddea9a24072796354d07e81c47b6cc8761b21a6448845b088cf80e1661d9e889b0ed5474d3dc76756
    HEAD_REF master
    PATCHES
        "${CUDNN_9_FIX}"
        "${CUDA_THRUST_MISSING_HEADER_FIX}"
        cmake-fixes.patch
        more-fixes.patch
        fix-build.patch
        clang-cl.patch
        cuda-adjustments.patch
        fix-api-export.patch
        fxdiv.patch
        protoc.patch
        fix-sleef.patch
        fix-glog.patch
        fix-msvc-ICE.patch
        fix-calculate-minloglevel.patch
        force-cuda-include.patch
        fix-aten-cutlass.patch
        fix-build-error-with-fmt11.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # We must use generated header files

vcpkg_from_github(
    OUT_SOURCE_PATH src_kineto
    REPO pytorch/kineto
    REF 49e854d805d916b2031e337763928d2f8d2e1fbf
    SHA512 ae63d48dc5b8ac30c38c2ace60f16834c7e9275fa342dc9f109d4fbc87b7bd674664f6413c36d0c1ab5a7da786030a4108d83daa4502b2f30239283ea3acdb16
    HEAD_REF main
    PATCHES
      kineto.patch
)
file(COPY "${src_kineto}/" DESTINATION "${SOURCE_PATH}/third_party/kineto")

vcpkg_from_github(
    OUT_SOURCE_PATH src_cudnn
    REPO NVIDIA/cudnn-frontend # new port ?
    REF 12f35fa2be5994c1106367cac2fba21457b064f4
    SHA512 a7e4bf58f82ca0b767df35da1b3588e2639ea2ef22ed0c47e989fb4cde5a28b0605b228b42fcaefbdf721bfbb91f2a9e7d41352ff522bd80b63db6d27e44ec20
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
#set(PYTHON3 "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python${VCPKG_HOST_EXECUTABLE_SUFFIX}")
message(STATUS "Using Python3: ${PYTHON3}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    dist    USE_DISTRIBUTED # MPI, Gloo, TensorPipe
    zstd    USE_ZSTD
    fbgemm  USE_FBGEMM
    opencv  USE_OPENCV
    # These are alternatives !
    # tbb     USE_TBB
    # tbb     AT_PARALLEL_NATIVE_TBB # AT_PARALLEL_ are alternatives
    # openmp  USE_OPENMP
    # openmp  AT_PARALLEL_OPENMP # AT_PARALLEL_ are alternatives
    leveldb USE_LEVELDB
    opencl  USE_OPENCL
    cuda    USE_CUDA
    cuda    USE_CUDNN
    cuda    USE_NCCL
    cuda    USE_SYSTEM_NCCL
    cuda    USE_NVRTC
    cuda    AT_CUDA_ENABLED
    cuda    AT_CUDNN_ENABLED
    cuda    USE_MAGMA
    vulkan  USE_VULKAN
    #vulkan  USE_VULKAN_SHADERC_RUNTIME
    vulkan  USE_VULKAN_RELAXED_PRECISION
    rocm    USE_ROCM  # This is an alternative to cuda not a feature! (Not in vcpkg.json!) -> disabled
    llvm    USE_LLVM
    mpi     USE_MPI
    nnpack  USE_NNPACK  # todo: check use of `DISABLE_NNPACK_AND_FAMILY`
    nnpack  AT_NNPACK_ENABLED
    qnnpack USE_QNNPACK # todo: check use of `USE_PYTORCH_QNNPACK`
#   No feature in vcpkg yet so disabled. -> Requires numpy build by vcpkg itself
    python  BUILD_PYTHON
    python  USE_NUMPY
)

if("dist" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_TENSORPIPE=ON)
    endif()
    if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DUSE_LIBUV=ON)
    endif()
    list(APPEND FEATURE_OPTIONS -DUSE_GLOO=${VCPKG_TARGET_IS_LINUX})
endif()

if(VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS)
    list(APPEND FEATURE_OPTIONS -DINTERN_BUILD_MOBILE=ON)
else()
    list(APPEND FEATURE_OPTIONS -DINTERN_BUILD_MOBILE=OFF)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}
        -DCAFFE2_CUSTOM_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}
        -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON3}
        #-DPython3_EXECUTABLE:FILEPATH=${PYTHON3}
        -DCAFFE2_STATIC_LINK_CUDA=ON
        -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
        -DBUILD_CUSTOM_PROTOBUF=OFF
        -DUSE_LITE_PROTO=OFF
        -DBUILD_TEST=OFF
        -DATEN_NO_TEST=ON
        -DUSE_SYSTEM_LIBS=ON
        -DUSE_METAL=OFF
        -DUSE_PYTORCH_METAL=OFF
        -DUSE_PYTORCH_METAL_EXPORT=OFF
        -DUSE_GFLAGS=ON
        -DUSE_GLOG=ON
        -DUSE_LMDB=ON
        -DUSE_ITT=OFF
        -DUSE_ROCKSDB=ON
        -DUSE_OBSERVERS=OFF
        -DUSE_PYTORCH_QNNPACK=OFF
        -DUSE_KINETO=OFF
        -DUSE_ROCM=OFF
        -DUSE_NUMA=OFF
        -DUSE_SYSTEM_ONNX=ON
        -DUSE_SYSTEM_FP16=ON
        -DUSE_SYSTEM_EIGEN_INSTALL=ON
        -DUSE_SYSTEM_CPUINFO=ON
        -DUSE_SYSTEM_PTHREADPOOL=ON
        -DUSE_SYSTEM_PYBIND11=ON
        -DUSE_SYSTEM_ZSTD=ON
        -DUSE_SYSTEM_GLOO=ON
        -DUSE_SYSTEM_NCCL=ON
        -DUSE_SYSTEM_LIBS=ON
        -DUSE_SYSTEM_FXDIV=ON
        -DUSE_SYSTEM_SLEEF=ON
        -DBUILD_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DUSE_NNAPI=${VCPKG_TARGET_IS_ANDROID}
        ${BLAS_OPTIONS}
        # BLAS=MKL not supported in this port
        -DUSE_MKLDNN=OFF
        -DUSE_MKLDNN_CBLAS=OFF
        #-DCAFFE2_USE_MKL=ON
        #-DAT_MKL_ENABLED=ON
        -DAT_MKLDNN_ENABLED=OFF
        -DUSE_OPENCL=ON
        -DUSE_NUMPY=ON
        -DUSE_KINETO=OFF #
    OPTIONS_RELEASE
      -DPYTHON_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/python311.lib
    OPTIONS_DEBUG
      -DPYTHON_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/python311_d.lib
    MAYBE_UNUSED_VARIABLES
        USE_NUMA
        USE_SYSTEM_BIND11
        MKLDNN_CPU_RUNTIME
        PYTHON_LIBRARY
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME caffe2 CONFIG_PATH "share/cmake/Caffe2" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME torch CONFIG_PATH "share/cmake/Torch")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/torch/TorchConfig.cmake" "/../../../" "/../../")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/caffe2/Caffe2Config.cmake" "/../../../" "/../../")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/caffe2/Caffe2Config.cmake"
  "set(Caffe2_MAIN_LIBS torch_library)"
  "set(Caffe2_MAIN_LIBS torch_library)\nfind_dependency(Eigen3)")



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

# Cannot build python bindings yet
#if("python" IN_LIST FEATURES)
#  set(ENV{USE_SYSTEM_LIBS} 1)
#  vcpkg_replace_string("${SOURCE_PATH}/setup.py" "@TARGET_TRIPLET@" "${TARGET_TRIPLET}-rel")
#  vcpkg_replace_string("${SOURCE_PATH}/tools/setup_helpers/env.py" "@TARGET_TRIPLET@" "${TARGET_TRIPLET}-rel")
#  vcpkg_replace_string("${SOURCE_PATH}/torch/utils/cpp_extension.py" "@TARGET_TRIPLET@" "${TARGET_TRIPLET}-rel")
#  vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -x)
#endif()

set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled) # torch_global_deps.dll is empty.c and just for linking deps

set(config "${CURRENT_PACKAGES_DIR}/share/torch/TorchConfig.cmake")
file(READ "${config}" contents)
string(REGEX REPLACE "set\\\(NVTOOLEXT_HOME[^)]+" "set(NVTOOLEXT_HOME \"\$ENV{CUDA_PATH}\"" contents "${contents}")
#string(REGEX REPLACE "set\\\(NVTOOLEXT_HOME[^)]+" "set(NVTOOLEXT_HOME \"\${CMAKE_CURRENT_LIST_DIR}/../../tools/cuda/\"" contents "${contents}")
string(REGEX REPLACE "\\\${NVTOOLEXT_HOME}/lib/x64/nvToolsExt64_1.lib" "" contents "${contents}")
file(WRITE "${config}" "${contents}")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/torch/csrc/autograd/custom_function.h" "struct TORCH_API Function" "struct Function")
