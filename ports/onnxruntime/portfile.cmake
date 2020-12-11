# Only limited triplets supported
# x64-windows: x64-windows-static-md
# x64-linux
# No support for osx and uwp OS
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fail_port_install(ON_LIBRARY_LINKAGE "dynamic")
    vcpkg_fail_port_install(ON_TARGET "uwp")
    vcpkg_fail_port_install(ON_ARCH "arm" "arm64" "wasm32" "x86")
elseif(VCPKG_TARGET_IS_LINUX)
    vcpkg_fail_port_install(ON_ARCH "x86")
else()
    vcpkg_fail_port_install(ALWAYS)
endif()

set(ORT_REVISION "v1.5.3")

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
set(ONNXRUNTIME "onnxruntime.git")
set(ONNX_GITHUB_URL "https://github.com/microsoft/${ONNXRUNTIME}")

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


set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}")

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}/cmake"
  PREFER_NINJA
  OPTIONS
    -Donnxruntime_RUN_ONNX_TESTS=OFF
    -Donnxruntime_BUILD_WINML_TESTS=ON
    -Donnxruntime_GENERATE_TEST_REPORTS=ON
    -Donnxruntime_USE_CUDA=OFF
    -Donnxruntime_USE_FEATURIZERS=OFF
    -Donnxruntime_USE_JEMALLOC=OFF
    -Donnxruntime_USE_MIMALLOC_STL_ALLOCATOR=OFF
    -Donnxruntime_USE_MIMALLOC_ARENA_ALLOCATOR=OFF
    -Donnxruntime_BUILD_SHARED_LIB=ON
    -Donnxruntime_USE_EIGEN_FOR_BLAS=ON
    -Donnxruntime_USE_OPENBLAS=OFF
    -Donnxruntime_USE_DNNL=OFF
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
    -Donnxruntime_PYBIND_EXPORT_OPSCHEMA=OFF
    -Donnxruntime_ENABLE_MEMLEAK_CHECKER=OFF
    -DCMAKE_BUILD_TYPE=RelWithDebInfo
    -DONNX_ML=1
    -DONNX_NAMESPACE=onnx
    ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

message(STATUS "Copy libs and additional header files!")
# Copy lib and PDB files
if(VCPKG_TARGET_IS_WINDOWS)
  set(STATIC_LIB_EXTN "*.lib")
  set(DYN_LIB_EXTN "*.dll")
  set(SYM_FILE_EXTN "*.pdb")
elseif(VCPKG_TARGET_IS_LINUX) # !Winddows
  set(STATIC_LIB_EXTN "*.a")
  set(DYN_LIB_EXTN "*.(s|S)(o|O)")
  set(SYM_FILE_EXTN "*.pdb")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug") 
  # copy the onnxruntime_*.libs
  message(STATUS "Copying from ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
  file(GLOB DEBUG_LIBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${STATIC_LIB_EXTN})
  file(COPY
      ${DEBUG_LIBS}
      DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
      )
  # copy their corresponding *.pdbs
  if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB DEBUG_LIB_PDBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${SYM_FILE_EXTN})
    file(COPY
        ${DEBUG_LIB_PDBS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
  endif()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  # copy the onnxruntime_*.libs
  message(STATUS "Copying from ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
  file(GLOB DEBUG_LIBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${STATIC_LIB_EXTN})
  file(COPY
      ${DEBUG_LIBS}
      DESTINATION ${CURRENT_PACKAGES_DIR}/lib
      )

  # copy their corresponding *.pdbs
  if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB DEBUG_LIB_PDBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SYM_FILE_EXTN})
    file(COPY
        ${DEBUG_LIB_PDBS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )
  endif()
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
    file(GLOB_RECURSE EXT_LIBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/external/${EXTERNAL_MODULE}/${STATIC_LIB_EXTN})
    file(COPY
        ${EXT_LIBS}
        DESTINATION ${Destination}
        )
    file(GLOB_RECURSE EXT_LIB_PDBS LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/external/${EXTERNAL_MODULE}/${SYM_FILE_EXTN})
    file(COPY
        ${EXT_LIB_PDBS}
        DESTINATION ${Destination}
        )
  endforeach () # for all externam modules
endforeach() # for different linkage types

message(STATUS "Copy libs done, copying additional header files!")
# Copy additional header files
# 1. Copy missing orttraining header files
# TODO: Make changes in ORT souce repo to put all training header files under top level include dir
file(GLOB_RECURSE TRAINING_HEADERS LIST_DIRECTORIES false ${SOURCE_PATH}/orttraining/*.h)
file(COPY ${SOURCE_PATH}/orttraining/orttraining/core DESTINATION ${CURRENT_PACKAGES_DIR}/include/orttraining FOLLOW_SYMLINK_CHAIN FILES_MATCHING PATTERN "*.h")
# file(INSTALL ${SOURCE_PATH}/orttraining/orttraining/models DESTINATION ${CURRENT_PACKAGES_DIR}/include/orttraining FOLLOW_SYMLINK_CHAIN PATTERN "*.h")

# 2. copy headers from external modules
file(GLOB_RECURSE EXT_HEADERS LIST_DIRECTORIES false ${SOURCE_PATH}/cmake/external/onnx/onnx/*.h)
file(COPY ${EXT_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/onnxruntime/external/onnx/onnx)

file(GLOB_RECURSE EXT_HEADERS LIST_DIRECTORIES false ${SOURCE_PATH}/cmake/external/SafeInt/*.h)
file(COPY ${EXT_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/onnxruntime/external/SafeInt)

file(GLOB_RECURSE EXT_HEADERS LIST_DIRECTORIES false ${SOURCE_PATH}/cmake/external/protobuf/src/*.h)
file(COPY ${EXT_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/onnxruntime/external/protobuf/src)

file(GLOB_RECURSE EXT_HEADERS LIST_DIRECTORIES false ${SOURCE_PATH}/cmake/external/nsync/public/*.h)
file(COPY ${EXT_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/onnxruntime/external/nsync/public)

# Copy onnxruntime_config.h file
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug") 
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/onnxruntime_config.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/onnxruntime)
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/onnxruntime_config.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/orttraining)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/onnxruntime_config.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/onnxruntime)
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/onnxruntime_config.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/orttraining)
endif()

# Copy the license file
file(INSTALL
  ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

message(STATUS "Copy libs and headers done!")

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
