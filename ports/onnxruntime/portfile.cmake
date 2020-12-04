if(NOT TARGET_TRIPLET MATCHES "(x|X)64-(windows|linux)-static-md")
  vcpkg_fail_port_install(MESSAGE "${PORT} doesn't support ${TARGET_TRIPLET} currently" ALWAYS)
endif()

set(ORT_REVISION "v1.5.3")

# check out the `https://github.com/microsoft/onnxruntime/archive/${ORT_REVISION}.tar.gz`
# hash checksum can be obtained with `curl -L -o tmp.tgz ${URL} && vcpkg hash tmp.tgz`
#vcpkg_from_github(
#  OUT_SOURCE_PATH SOURCE_PATH
#  REPO microsoft/onnxruntime
#  REF aec4cb489e49a63fc8523ee3d22e406c2af9c22b
#  SHA512  965046f76083c36f728d74275b7db091abb43e8eb514b45fce4223a43c1d8a0825db79f8528f0a7a68e12e3419e3467a949177a9d8e54b8a853baa0394e6f4d7
#  HEAD_REF master
#  PATCHES
#    "CMakeLists.patch"
#)

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
set(ONNXRUNTIME "onnxruntime.git")
set(ONNX_GITHUB_URL "https://github.com/microsoft/${ONNXRUNTIME}")

#vcpkg_from_git(
#  OUT_SOURCE_PATH SOURCE_PATH
#  URL "${ONNX_GITHUB_URL}"
#  REF aec4cb489e49a63fc8523ee3d22e406c2af9c22b
#  PATCHES
#    "CMakeLists.patch"
#)

if(EXISTS "${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}")
  # Purge any local changes
  vcpkg_execute_required_process(
    COMMAND ${GIT} reset --hard
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
    LOGNAME build-${TARGET_TRIPLET})
  
  # 
  vcpkg_execute_required_process(
    COMMAND ${GIT} submodule sync --recursive
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
    LOGNAME build-${TARGET_TRIPLET})

  # 
  vcpkg_execute_required_process(
    COMMAND ${GIT} submodule update --init --recursive
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
    LOGNAME build-${TARGET_TRIPLET})

else()
  vcpkg_execute_required_process(
    COMMAND ${GIT} clone --recursive ${ONNX_GITHUB_URL} ${ONNXRUNTIME}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME build-${TARGET_TRIPLET})
endif()



if(VCPKG_TARGET_IS_WINDOWS)
#  list(APPEND FEATURE_OPTIONS  "Visual Studio 16 2019")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
#  list(APPEND FEATURE_OPTIONS -x64)
#  list(APPEND FEATURE_OPTIONS "host=x64")
endif()

set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}")

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}/cmake"
  PREFER_NINJA
  OPTIONS
    -Donnxruntime_RUN_ONNX_TESTS=OFF
    -Donnxruntime_BUILD_WINML_TESTS=ON
    -Donnxruntime_GENERATE_TEST_REPORTS=ON
    -Donnxruntime_USE_CUDA=OFF
    -Donnxruntime_CUDNN_HOME=
    -Donnxruntime_USE_FEATURIZERS=OFF
    -Donnxruntime_CUDA_HOME=
    -Donnxruntime_USE_JEMALLOC=OFF
    -Donnxruntime_USE_MIMALLOC_STL_ALLOCATOR=OFF
    -Donnxruntime_USE_MIMALLOC_ARENA_ALLOCATOR=OFF
    -Donnxruntime_BUILD_SHARED_LIB=ON
    -Donnxruntime_USE_EIGEN_FOR_BLAS=ON
    -Donnxruntime_USE_OPENBLAS=OFF
    -Donnxruntime_USE_DNNL=OFF
    -Donnxruntime_DNNL_GPU_RUNTIME=
    -Donnxruntime_DNNL_OPENCL_ROOT=
    -Donnxruntime_USE_MKLML=OFF
    -Donnxruntime_USE_NNAPI_BUILTIN=OFF
    -Donnxruntime_USE_RKNPU=OFF
    -Donnxruntime_USE_OPENMP=OFF
    -Donnxruntime_USE_TVM=OFF
    -Donnxruntime_USE_LLVM=OFF
    -Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF
    -Donnxruntime_USE_VITISAI=OFF
    -Donnxruntime_USE_NUPHAR=OFF
    -Donnxruntime_USE_TENSORRT=OFF
    -Donnxruntime_TENSORRT_HOME=
    -Donnxruntime_USE_MIGRAPHX=OFF
    -Donnxruntime_MIGRAPHX_HOME=
    -Donnxruntime_CROSS_COMPILING=OFF
    -Donnxruntime_DISABLE_CONTRIB_OPS=OFF
    -Donnxruntime_DISABLE_ML_OPS=OFF
    -Donnxruntime_DISABLE_RTTI=OFF
    -Donnxruntime_DISABLE_EXCEPTIONS=OFF
    -Donnxruntime_DISABLE_ORT_FORMAT_LOAD=OFF
    -Donnxruntime_MINIMAL_BUILD=OFF
    -Donnxruntime_ENABLE_LANGUAGE_INTEROP_OPS=OFF
    -Donnxruntime_USE_DML=OFF
    -Donnxruntime_USE_WINML=OFF
    -Donnxruntime_USE_TELEMETRY=OFF
    -Donnxruntime_ENABLE_LTO=OFF
    -Donnxruntime_USE_ACL=OFF
    -Donnxruntime_USE_ACL_1902=OFF
    -Donnxruntime_USE_ACL_1905=OFF
    -Donnxruntime_USE_ACL_1908=OFF
    -Donnxruntime_USE_ACL_2002=OFF
    -Donnxruntime_USE_ARMNN=OFF
    -Donnxruntime_ARMNN_RELU_USE_CPU=ON
    -Donnxruntime_ARMNN_BN_USE_CPU=ON
    -Donnxruntime_ENABLE_NVTX_PROFILE=OFF
    -Donnxruntime_ENABLE_TRAINING=ON
    -Donnxruntime_USE_HOROVOD=OFF
    -Donnxruntime_USE_NCCL=ON
    -Donnxruntime_BUILD_BENCHMARKS=OFF
    -Donnxruntime_USE_ROCM=OFF
    -Donnxruntime_ROCM_HOME=
    -Donnxruntime_PYBIND_EXPORT_OPSCHEMA=OFF
    -Donnxruntime_ENABLE_MEMLEAK_CHECKER=OFF
    -DCMAKE_BUILD_TYPE=RelWithDebInfo
    ${FEATURE_OPTIONS}
  OPTIONS_RELEASE

  OPTIONS_DEBUG

)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug") 
    # copy the onnxruntime_*.libs
    message(STATUS "Copying from ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    file(GLOB DEBUG_LIBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib)
    file(COPY
        ${DEBUG_LIBS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
    # copy their corresponding *.pdbs
    file(GLOB DEBUG_LIB_PDBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.pdb)
    file(COPY
        ${DEBUG_LIB_PDBS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    # copy the onnxruntime_*.libs
    message(STATUS "Copying from ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(GLOB DEBUG_LIBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib)
    file(COPY
        ${DEBUG_LIBS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )

    # copy their corresponding *.pdbs
    file(GLOB DEBUG_LIB_PDBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-release/*.pdb)
    file(COPY
        ${DEBUG_LIB_PDBS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )
  endif()

  # copy library from external modules
  foreach(BUILD_TYPE rel dbg)
    if(${BUILD_TYPE} STREQUAL "dbg")
      set(Destination "${CURRENT_PACKAGES_DIR}/debug/lib")
    else()
      set(Destination "${CURRENT_PACKAGES_DIR}/lib")
    endif()  
    foreach(EXTERNAL_MODULE flatbuffers onnx protobuf re2)
      message(STATUS "Copying from ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/external/${EXTERNAL_MODULE}")
      file(GLOB_RECURSE EXT_LIBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/external/${EXTERNAL_MODULE}/*.lib)
      file(COPY
          ${EXT_LIBS}
          DESTINATION ${Destination}
          )
    endforeach ()
  endforeach()

elseif(VCPKG_TARGET_IS_LINUX) # !Winddows
message(STATUS "Copy libs and pdbs on Linux!")
endif()

file(INSTALL
  ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

message(STATUS "Copy libs and pdbs done!")

# Remove bin directories for static build, both debug and release build
# onnx_test_runner.exe, onnxruntime.dll
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_copy_pdbs()

message(STATUS "Installing done")
