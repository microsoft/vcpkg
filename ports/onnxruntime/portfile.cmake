string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/onnxruntime
    REF v1.19.0
    SHA512 da0cd297ffc11e2f627a91e55476952b2511e36bf97fb0d9a0a8b1e2cbd12a451e1a8ead1581bfe03d08c97946f0938434edd4637cbeb28f7007533d4b37ee55
    PATCHES
        fix-pr-21348.patch # cmake, source changes of PR 21348
        fix-cmake.patch
        fix-cmake-cuda.patch
        fix-cmake-tensorrt.patch # TENSORRT_ROOT is not defined, use CUDAToolkit to search TensorRT
        fix-llvm-rc-unicode.patch
        fix-clang-cl-simd-compile.patch
)
# copied from PR 21348 to reduce patch size
file(COPY "${CMAKE_CURRENT_LIST_DIR}/onnxruntime_external_deps.cmake" DESTINATION "${SOURCE_PATH}/cmake/external")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/project-config-template.cmake" DESTINATION "${SOURCE_PATH}/cmake")

# https://github.com/microsoft/onnxruntime/blob/26250ae74d2c9a3c6860625ba4a147ddfb936907/cmake/deps.txt#L20-L25
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH EIGEN_SOURCE_PATH
    REPO libeigen/eigen
    REF e7248b26a1ed53fa030c5c459f7ea095dfd276ac
    SHA512 2ede6fa56b8374cd5618a9cca9f3666909255277d0fe23eb54266972a9ab4e6c8c00abcb8fab918ea45b4aec37a3d316ca01107ff082dc9f19851df58d7ac80d
)

find_program(PROTOC NAMES protoc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using protoc: ${PROTOC}")

find_program(FLATC NAMES flatc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using flatc: ${FLATC}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH "${PYTHON3}" PATH)
message(STATUS "Using python3: ${PYTHON3}")

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" onnxruntime/core/flatbuffers/schema/compile_schema.py --flatc "${FLATC}"
    LOGNAME compile_schema
    WORKING_DIRECTORY "${SOURCE_PATH}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        python    onnxruntime_ENABLE_PYTHON
        training  onnxruntime_ENABLE_TRAINING
        training  onnxruntime_ENABLE_TRAINING_APIS
        # training  onnxruntime_ENABLE_TRAINING_OPS
        cuda      onnxruntime_USE_CUDA
        cuda      onnxruntime_USE_CUDA_NHWC_OPS
        openvino  onnxruntime_USE_OPENVINO
        tensorrt  onnxruntime_USE_TENSORRT
        tensorrt  onnxruntime_USE_TENSORRT_BUILTIN_PARSER
        directml  onnxruntime_USE_DML
        directml  onnxruntime_USE_CUSTOM_DIRECTML
        winml     onnxruntime_USE_WINML
        coreml    onnxruntime_USE_COREML
        mimalloc  onnxruntime_USE_MIMALLOC
        valgrind  onnxruntime_USE_VALGRIND
        xnnpack   onnxruntime_USE_XNNPACK
        nnapi     onnxruntime_USE_NNAPI_BUILTIN
        azure     onnxruntime_USE_AZURE
        llvm      onnxruntime_USE_LLVM
        rocm      onnxruntime_USE_ROCM
        test      onnxruntime_BUILD_UNIT_TESTS
        test      onnxruntime_BUILD_BENCHMARKS
        test      onnxruntime_RUN_ONNX_TESTS
        framework onnxruntime_BUILD_APPLE_FRAMEWORK
        framework onnxruntime_BUILD_OBJC
        nccl      onnxruntime_USE_NCCL
        mpi       onnxruntime_USE_MPI
    INVERTED_FEATURES
        cuda      onnxruntime_USE_MEMORY_EFFICIENT_ATTENTION
)

if("tensorrt" IN_LIST FEATURES)
    if(DEFINED TENSORRT_ROOT)
        message(STATUS "Using TensorRT: ${TENSORRT_ROOT}")
        list(APPEND FEATURE_OPTIONS "-Donnxruntime_TENSORRT_HOME:PATH=${TENSORRT_ROOT}")
    endif()
endif()

# see tools/ci_build/build.py
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPython_EXECUTABLE:FILEPATH=${PYTHON3}"
        "-DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}"
        "-DONNX_CUSTOM_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}"
        -DBUILD_PKGCONFIG_FILES=${BUILD_SHARED}
        -Donnxruntime_USE_VCPKG=ON
        # the port doesn't use eigen3 in vcpkg
        -DEigen3_FOUND=OFF # force include(eigen)
        -Donnxruntime_USE_PREINSTALLED_EIGEN=ON
        -Deigen_SOURCE_PATH=${EIGEN_SOURCE_PATH}
        -Donnxruntime_BUILD_SHARED_LIB=${BUILD_SHARED}
        -Donnxruntime_BUILD_WEBASSEMBLY=OFF
        -Donnxruntime_CROSS_COMPILING=${VCPKG_CROSSCOMPILING}
        -Donnxruntime_USE_EXTENSIONS=OFF
        -Donnxruntime_USE_NNAPI_BUILTIN=${VCPKG_TARGET_IS_ANDROID}
        -Donnxruntime_ENABLE_CPUINFO=ON
        -Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF
        -Donnxruntime_ENABLE_BITCODE=${VCPKG_TARGET_IS_IOS}
        -Donnxruntime_ENABLE_PYTHON=OFF
        -Donnxruntime_ENABLE_EXTERNAL_CUSTOM_OP_SCHEMAS=OFF
        -Donnxruntime_ENABLE_LAZY_TENSOR=OFF
        -Donnxruntime_DISABLE_RTTI=OFF
        -Donnxruntime_DISABLE_ABSEIL=OFF
        -Donnxruntime_USE_NEURAL_SPEED=OFF
        -DUSE_NEURAL_SPEED=OFF
        # for ORT_BUILD_INFO
        "-DORT_GIT_COMMIT:STRING=26250ae74d2c9a3c6860625ba4a147ddfb936907"
        "-DORT_GIT_BRANCH:STRING=v${VERSION}"
        --compile-no-warning-as-error
    OPTIONS_DEBUG
        -Donnxruntime_ENABLE_MEMLEAK_CHECKER=OFF
        -Donnxruntime_ENABLE_MEMORY_PROFILE=OFF
        -Donnxruntime_DEBUG_NODE_INPUTS_OUTPUTS=1
    MAYBE_UNUSED_VARIABLES
        onnxruntime_BUILD_WEBASSEMBLY
        onnxruntime_TENSORRT_PLACEHOLDER_BUILDER
        onnxruntime_USE_CUSTOM_DIRECTML
        Python_EXECUTABLE
        ORT_GIT_COMMIT
        ORT_GIT_BRANCH
)

if("cuda" IN_LIST FEATURES)
    vcpkg_cmake_build(TARGET onnxruntime_providers_cuda LOGFILE_BASE build-cuda)
endif()
if("tensorrt" IN_LIST FEATURES)
    vcpkg_cmake_build(TARGET onnxruntime_providers_tensorrt LOGFILE_BASE build-tensorrt)
endif()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/onnxruntime)
if(BUILD_SHARED)
    vcpkg_fixup_pkgconfig() # pkg_check_modules(libonnxruntime)
endif()

# cmake function which relocates the onnxruntime_providers_* library before vcpkg_copy_pdbs()
function(relocate_ort_providers PROVIDER_NAME)
    if(VCPKG_TARGET_IS_WINDOWS AND (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic"))
        # the target is expected to be used without the .lib files
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${PROVIDER_NAME}.dll"
                    "${CURRENT_PACKAGES_DIR}/debug/bin/${PROVIDER_NAME}.dll")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${PROVIDER_NAME}.dll"
                    "${CURRENT_PACKAGES_DIR}/bin/${PROVIDER_NAME}.dll")
    endif()
endfunction()

if("cuda" IN_LIST FEATURES)
    relocate_ort_providers(onnxruntime_providers_cuda)
endif()
if("tensorrt" IN_LIST FEATURES)
    relocate_ort_providers(onnxruntime_providers_tensorrt)
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/bin"
        "${CURRENT_PACKAGES_DIR}/bin"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
