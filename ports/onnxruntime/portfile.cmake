# Only limited triplets supported
# x64-windows: x64-windows-static-md
# x64-linux
# No support for osx and uwp OS
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 
    vcpkg_fail_port_install(ON_ARCH "arm" "arm64" "wasm32" "x86" ON_TARGET "uwp")
elseif(VCPKG_TARGET_IS_LINUX)
    vcpkg_fail_port_install(ON_ARCH "x86")
else()
    vcpkg_fail_port_install(ALWAYS)
endif()

set(ORT_REVISION "v1.5.3")
#Todo: Move to tag rathter than commit hash
# set(ORT_COMMIT_HASH "3b3e698674dca2014b91fb617e2c4f22ffd0c5c9")
set(ORT_COMMIT_HASH "6c2162e97add696e9f7d0377dba322a4d1fe05cd")

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

# install pip
vcpkg_from_github(
    OUT_SOURCE_PATH PYFILE_PATH
    REPO pypa/get-pip
    REF 667abf5829986a5e708dc2575fe12c8ad2ce14a4
    SHA512 59cf8dd4fd699c8ea46eb890c8287924c15a096b8a14d8b242fdc36becdaa0c1d67f0afc268f5507d1621b4d6ded85f0fb350cee1f8d39b496d8af980f871857
    HEAD_REF master
)
execute_process(COMMAND ${PYTHON3} ${PYFILE_PATH}/get-pip.py)

# install numpy 
vcpkg_execute_required_process(COMMAND ${PYTHON3} -m pip install --user -U numpy WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequesits-pip-${TARGET_TRIPLET})

vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
vcpkg_add_to_path(${NINJA_PATH})
set(ONNXRUNTIME "onnxruntime.git")
set(ONNX_GITHUB_URL "https://github.com/microsoft/${ONNXRUNTIME}")

# Clone ORT repo
if(EXISTS "${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}")
  # Purge any local changes
  vcpkg_execute_required_process(
    COMMAND ${GIT} clean -xfd
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
    LOGNAME build-${TARGET_TRIPLET}
    )

  vcpkg_execute_required_process(
    COMMAND ${GIT} submodule foreach --recursive git clean -xfdf
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
    LOGNAME build-${TARGET_TRIPLET})

else()
  # Clone ORT Repo
  vcpkg_execute_required_process(
    COMMAND ${GIT} clone --recursive ${ONNX_GITHUB_URL} ${ONNXRUNTIME}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME build-${TARGET_TRIPLET}
    )
endif()

# Checkout the commit sha1
vcpkg_execute_required_process(
  COMMAND ${GIT} reset --hard ${ORT_COMMIT_HASH}
  WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
  LOGNAME build-${TARGET_TRIPLET}
  )

vcpkg_execute_required_process(
  COMMAND ${GIT} submodule foreach --recursive git reset --hard
  WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
  LOGNAME build-${TARGET_TRIPLET}
  )

# Todo: Check if we need to do the sync
#vcpkg_execute_required_process(
#COMMAND ${GIT} submodule sync --recursive
#WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
#LOGNAME build-${TARGET_TRIPLET})

vcpkg_execute_required_process(
  COMMAND ${GIT} submodule update --init --recursive
  WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}
  LOGNAME build-${TARGET_TRIPLET}
  )

set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${ONNXRUNTIME}")

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}/cmake"
  PREFER_NINJA
  OPTIONS
    -Donnxruntime_ENABLE_PYTHON=ON
    -Donnxruntime_ENABLE_TRAINING=ON
    -Donnxruntime_BUILD_SHARED_LIB=ON
    -Donnxruntime_USE_MPI=ON
    -Donnxruntime_ENABLE_MEMLEAK_CHECKER=OFF
    -Donnxruntime_BUILD_WINML_TESTS=ON
    -Donnxruntime_GENERATE_TEST_REPORTS=ON
    -Donnxruntime_USE_EIGEN_FOR_BLAS=ON
    -Donnxruntime_ARMNN_RELU_USE_CPU=ON
    -Donnxruntime_ARMNN_BN_USE_CPU=ON    
    -Donnxruntime_USE_NCCL=ON        
    -Donnxruntime_RUN_ONNX_TESTS=OFF
    -Donnxruntime_USE_FEATURIZERS=OFF
    -Donnxruntime_USE_CUDA=OFF    
    -Donnxruntime_USE_JEMALLOC=OFF
    -Donnxruntime_USE_MIMALLOC_STL_ALLOCATOR=OFF
    -Donnxruntime_USE_MIMALLOC_ARENA_ALLOCATOR=OFF
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
    -Donnxruntime_ENABLE_NVTX_PROFILE=OFF
    -Donnxruntime_USE_HOROVOD=OFF
    -Donnxruntime_BUILD_BENCHMARKS=OFF
    -Donnxruntime_USE_ROCM=OFF
    -Donnxruntime_PYBIND_EXPORT_OPSCHEMA=OFF
    -DCMAKE_BUILD_TYPE=RelWithDebInfo
    -DONNX_ML=ON
    -DONNX_NAMESPACE=onnx
    ${FEATURE_OPTIONS}
    -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()

message(STATUS "Copy libs and additional header files!")
# Copy lib and PDB files
if(VCPKG_TARGET_IS_WINDOWS)
  set(STATIC_LIB_EXTN "*.lib")
  set(SYM_FILE_EXTN "*.pdb")
elseif(VCPKG_TARGET_IS_LINUX)
  set(STATIC_LIB_EXTN "*.a")
  set(SYM_FILE_EXTN "*.pdb")
endif()

# Copy all libraries and PDBs
foreach(BUILD_TYPE rel dbg)
  if(${BUILD_TYPE} STREQUAL "dbg")    
    set(SRCBASEDIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/debug/lib")
  else()
    set(SRCBASEDIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/lib")
  endif()

  file(GLOB_RECURSE ORT_LIBS LIST_DIRECTORIES false ${SRCBASEDIR}/${STATIC_LIB_EXTN})
  file(COPY ${ORT_LIBS} DESTINATION ${DESTBASEDIR})

  #Todo: 1. PDB's are contributing to 6GiB to the total package size of 10GiB
  # Disabling it for time, enable back once we have fixed other issue
  if(FALSE)
    file(GLOB_RECURSE ORT_LIB_PDBS LIST_DIRECTORIES false ${SRCBASEDIR}/${SYM_FILE_EXTN})
    file(COPY ${ORT_LIB_PDBS} DESTINATION ${DESTBASEDIR})
  endif()
endforeach()

message(STATUS "Copy libs done, copying additional header files!")

# Copy additional header files
# TODO: Make changes in ORT souce repo to put all training header files under top level include dir

# 1. Copy header files from top level include directories
# Todo: Investigate why these headers files are not copied by vcpkg 
set(SRCBASEDIR "${SOURCE_PATH}/include/onnxruntime/core")
set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/include/onnxruntime/core")
foreach(MOD
      platform/
      graph/
      session/
      optimizer/
      providers/
      )
  file(COPY
    ${SRCBASEDIR}/${MOD}
    DESTINATION ${DESTBASEDIR}/${MOD}
    FOLLOW_SYMLINK_CHAIN
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
    PATTERN "*.inc"
    )
endforeach()

# 2. Copy missing external header files from build output folders. These are generaterd by build
# e.g. onnx-data.pb.h
# Trailing '/' is significant. Without it copying 'mydir' folder would be installed under Destination.
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  set(SRCBASEDIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/external")
  set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/include/onnxruntime/external")
  foreach(MOD onnx/onnx/)   # Placeholder to put more directories ,if needed!.
    file(COPY ${SRCBASEDIR}/${MOD} DESTINATION ${DESTBASEDIR}/${MOD} FOLLOW_SYMLINK_CHAIN FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN ".inc")
  endforeach() 
endif()

# 3. Copy header files from source core directories
# Todo: Check if we need to copy this: core/providers/nuphar/compiler/x86/op_ir_creator/all_ops.h
set(SRCBASEDIR "${SOURCE_PATH}/onnxruntime/core")
set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/include/onnxruntime/core")
set(MOD "")
foreach(MOD 
      common/ 
      framework/
      graph/
      platform/
      optimizer/
      providers/
      session/
      util/
      )
  file(COPY 
    ${SRCBASEDIR}/${MOD} 
    DESTINATION ${DESTBASEDIR}/${MOD} 
    FOLLOW_SYMLINK_CHAIN 
    FILES_MATCHING
    PATTERN "*.h" 
    PATTERN "*.hpp" 
    PATTERN "*.inc"
    PATTERN "cuda/atomic" EXCLUDE     #These paths under providers don't have any header files to be copied
    PATTERN "cuda/cu_inc" EXCLUDE
    PATTERN "cuda/multi_tensor" EXCLUDE
    PATTERN "nuphar/compiler/x86/op_ir_creator" EXCLUDE
    PATTERN "nuphar/scripts" EXCLUDE
    PATTERN "rocm/atomic" EXCLUDE
    PATTERN "rocm/cu_inc" EXCLUDE
    PATTERN "rocm/math" EXCLUDE
    )
endforeach()

# 4. Copy external header files from source folders
set(SRCBASEDIR "${SOURCE_PATH}/cmake/external")
set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/include/onnxruntime/external")
set(MOD "")
foreach(MOD 
      optional-lite/include/nonstd/
      optional-lite/test/
      onnx/onnx/common/
      onnx/onnx/optimizer/
      onnx/onnx/shape_inference/
      onnx/onnx/version_converter/
      onnx/third_party/benchmark/include/
      onnx/third_party/benchmark/src/
      onnx/third_party/benchmark/test/
      onnx/third_party/pybind11/include/
      SafeInt/safeint/Archive/releases/
      protobuf/src/google/
      nsync/public/
    )
  file(COPY
    ${SRCBASEDIR}/${MOD}
    DESTINATION ${DESTBASEDIR}/${MOD} 
    FOLLOW_SYMLINK_CHAIN
    FILES_MATCHING 
    PATTERN "*.h"
    PATTERN "*.hpp"
    PATTERN "*.inc"
    PATTERN "protobuf/util/internal/testdata" EXCLUDE # protobuf/src/google/ subfolders to skip
    PATTERN "protobuf/testdata" EXCLUDE
    )
endforeach()

# Now copy files from folders that does need to be copied recursively
set(MOD "")
foreach(MOD 
    SafeInt/safeint
    SafeInt/safeint/Test
    onnx/onnx
    onnx/onnx/defs
    onnx/onnx/defs/tensor
    onnx/third_party/pybind11/tests
    )
  set(EXT_ADDL_HDRS "")
  file(GLOB EXT_ADDL_HDRS LIST_DIRECTORIES false ${SRCBASEDIR}/${MOD}/*.h  ${SRCBASEDIR}/${MOD}/*.hpp)
  file(COPY ${EXT_ADDL_HDRS} DESTINATION ${DESTBASEDIR}/${MOD})
endforeach()

# 4. Copy training header files from sources directories
set(SRCBASEDIR "${SOURCE_PATH}/orttraining/orttraining")
set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/include/orttraining")
set(MOD "")
foreach(MOD
      core/
      models/mnist/
      models/runner/ 
      test/gradient/
      test/graph/
      test/optimizer/ 
      training_ops/
      )
  file(COPY 
    ${SRCBASEDIR}/${MOD} 
    DESTINATION ${DESTBASEDIR}/${MOD} 
    FOLLOW_SYMLINK_CHAIN 
    FILES_MATCHING 
    PATTERN "*.h" 
    PATTERN "*.hpp" 
    PATTERN "*.inc"
    PATTERN "rocm/activation" EXCLUDE  # All these folders under training_ops do not have header files!
    PATTERN "rocm/collective" EXCLUDE
    PATTERN "rocm/loss" EXCLUDE
    PATTERN "rocm/math" EXCLUDE
    PATTERN "rocm/optimizer" EXCLUDE
    PATTERN "rocm/reduction" EXCLUDE
    )
endforeach()

# Now copy files from folders that does need to be copied recursively
set(MOD "")
foreach(MOD
    test/training_ops
    )
  set(EXT_ADDL_HDRS "")
  file(GLOB EXT_ADDL_HDRS LIST_DIRECTORIES false ${SRCBASEDIR}/${MOD}/*.h  ${SRCBASEDIR}/${MOD}/*.hpp)
  file(COPY ${EXT_ADDL_HDRS} DESTINATION ${DESTBASEDIR}/${MOD})
endforeach()

# 5. Copy Test header files from sources directories
set(SRCBASEDIR "${SOURCE_PATH}/onnxruntime/test")
set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/include/onnxruntime/test")
set(MOD "")
foreach(MOD 
      util/include/ 
      framework/
      )
  file(COPY
    ${SRCBASEDIR}/${MOD} 
    DESTINATION ${DESTBASEDIR}/${MOD} 
    FOLLOW_SYMLINK_CHAIN 
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
    PATTERN "*.inc"
    PATTERN "cuda" EXCLUDE
    )
endforeach()

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

# Copy python packages and libraries.
set(SRCBASEDIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/onnxruntime")
set(DESTBASEDIR "${CURRENT_PACKAGES_DIR}/share/onnxruntime")

file(COPY 
  ${SRCBASEDIR}/ 
  DESTINATION ${DESTBASEDIR}
  )
# Remove bin directories for static build, both debug and release build
# onnx_test_runner.exe, onnxruntime.dll
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

# Remove empty directories that are created during copy operations
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/onnxruntime/external/SafeInt/safeint/Archive/releases/8")

#Todo: 2. PDB's are contributing to 6GiB to the total package size of 10GiB
# Disabling it for time, enable back once we have fixed other issue
if(FALSE)
  vcpkg_copy_pdbs()
endif()

message(STATUS "Installing done!")
