
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/pytorch
    REF "v${VERSION}"
    SHA512 a913a466324a65fa3d79c5e9ad4d605fc7976f0134fda2f81aaa3cea29d56926604999b8a238759646d211e63b47bbb446cdffa86ca8defd8159f11e30301289
    HEAD_REF master
    PATCHES
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
        fix-calculate-minloglevel.patch
        force-cuda-include.patch
        fix-aten-cutlass.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/caffe2/core/macros.h") # We must use generated header files

vcpkg_from_github(
    OUT_SOURCE_PATH src_kineto
    REPO pytorch/kineto
    REF d9753139d181b9ff42872465aac0e5d3018be415
    SHA512 f037fac78e566c40108acf9eace55a8f67a2c5b71f298fd3cd17bf22cf05240c260fd89f017fa411656a7505ec9073a06a3048e191251d5cfc4b52c237b37d0b
    HEAD_REF main
    PATCHES
      kineto.patch
)
file(COPY "${src_kineto}/" DESTINATION "${SOURCE_PATH}/third_party/kineto")

vcpkg_from_github(
    OUT_SOURCE_PATH src_cudnn
    REPO NVIDIA/cudnn-frontend # new port ?
    REF 2533f5e5c1877fd76266133c1479ef1643ce3a8b #  1.6.1 
    SHA512 8caacdf9f7dbd6ce55507f5f7165db8640b681e2a7dfd6a841de8eaa3489cff5ba41d11758cc464320b2ff9a491f8234e1749580cf43cac702f07cf82611e084
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
    PACKAGES typing-extensions pyyaml 
    # numpy
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

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # torch_cpu is too large to link statically (exceeds 4GB limit)
    # INTERN_USE_EIGEN_BLAS=OFF is to make sure it uses system eigen blas
    list(APPEND FEATURE_OPTIONS -DINTERN_BUILD_MOBILE=ON -DINTERN_USE_EIGEN_BLAS=OFF -DUSE_BLAS=OFF)
    list(APPEND FEATURE_OPTIONS -DMSVC_Z7_OVERRIDE=OFF) # Reduce the size

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
        -DBUILD_PYTHON=OFF
        -DUSE_LITE_PROTO=OFF
        -DBUILD_TEST=OFF
        -DATEN_NO_TEST=ON
        -DUSE_SYSTEM_LIBS=ON
        -DUSE_METAL=OFF
        -DUSE_PYTORCH_METAL=OFF
        -DUSE_PYTORCH_METAL_EXPORT=OFF
        -DUSE_FBGEMM=ON
        -DUSE_PYTORCH_QNNPACK:BOOL=OFF
        -DUSE_GFLAGS=ON
        -DUSE_GLOG=ON
        -DUSE_ITT=OFF
        -DUSE_ROCKSDB=ON
        -DUSE_OBSERVERS=OFF
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
        -DUSE_KINETO=OFF #
    # Should be enabled in-future along with the "python" feature (currently disabled)
    # OPTIONS_RELEASE
    #  -DPYTHON_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/python311.lib
    # OPTIONS_DEBUG
    #  -DPYTHON_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/python311_d.lib
    MAYBE_UNUSED_VARIABLES
        USE_NUMA
        USE_SYSTEM_BIND11
        MKLDNN_CPU_RUNTIME
        PYTHON_LIBRARY
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME torch CONFIG_PATH "share/cmake/Torch")
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
