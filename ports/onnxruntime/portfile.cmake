if("framework" IN_LIST FEATURES)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/onnxruntime
    REF "v${VERSION}"
    SHA512 63f1b8a8ede1d45d68c341c0df60ee360e689d513626ac2ad07b50930651321bd6cf661f628bd6768c10a0b3029ced51ad0df05060be028f0e820512ad4c5bc1
    PATCHES
        fix-cmake.patch
        fix-source-flatbuffers.patch
        fix-sources.patch
        fix-clang-cl-simd-compile.patch
        fix-llvm-rc-unicode.patch
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/onnxruntime_vcpkg_deps.cmake" DESTINATION "${SOURCE_PATH}/cmake/external")

find_program(PROTOC NAMES protoc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using protoc: ${PROTOC}")

find_program(FLATC NAMES flatc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH)
message(STATUS "Using flatc: ${FLATC}")

set(SCHEMA_DIR "${SOURCE_PATH}/onnxruntime/core/flatbuffers/schema")
vcpkg_execute_required_process(
    COMMAND ${FLATC} --cpp --scoped-enums --filename-suffix ".fbs" ort.fbs ort_training_checkpoint.fbs
    LOGNAME codegen-flatc-cpp
    WORKING_DIRECTORY "${SCHEMA_DIR}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        python    onnxruntime_ENABLE_PYTHON
        python    onnxruntime_ENABLE_LANGUAGE_INTEROP_OPS
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
        test      onnxruntime_BUILD_UNIT_TESTS
        test      onnxruntime_BUILD_BENCHMARKS
        test      onnxruntime_RUN_ONNX_TESTS
        framework onnxruntime_BUILD_APPLE_FRAMEWORK
        framework onnxruntime_BUILD_OBJC
        nccl      onnxruntime_USE_NCCL
        mpi       onnxruntime_USE_MPI
        minimal   onnxruntime_ORT_MINIMAL_BUILD
    INVERTED_FEATURES
        abseil    onnxruntime_DISABLE_ABSEIL
        cuda      onnxruntime_USE_MEMORY_EFFICIENT_ATTENTION
)

if("python" IN_LIST FEATURES)
    x_vcpkg_get_python_packages(
        PYTHON_VERSION 3
        PACKAGES numpy sympy
        OUT_PYTHON_VAR PYTHON3
    )
else()
    vcpkg_find_acquire_program(PYTHON3)
endif()
get_filename_component(PYTHON_PATH "${PYTHON3}" PATH)
message(STATUS "Using python3: ${PYTHON3}")
vcpkg_add_to_path(PREPEND "${PYTHON_PATH}")

# see tools/ci_build/build.py
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPython_EXECUTABLE:FILEPATH=${PYTHON3}
        -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC}
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DBUILD_PKGCONFIG_FILES=${BUILD_SHARED}
        -Donnxruntime_BUILD_SHARED_LIB=${BUILD_SHARED}
        -Donnxruntime_BUILD_WEBASSEMBLY=OFF
        -Donnxruntime_CROSS_COMPILING=${VCPKG_CROSSCOMPILING}
        -Donnxruntime_USE_FULL_PROTOBUF=OFF # minimalize protoc execution
        -Donnxruntime_USE_PREINSTALLED_EIGEN=ON
        -Donnxruntime_USE_EXTENSIONS=OFF
        -Donnxruntime_USE_NNAPI_BUILTIN=${VCPKG_TARGET_IS_ANDROID}
        -Donnxruntime_ENABLE_CPUINFO=ON
        -Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF
        -Donnxruntime_ENABLE_BITCODE=${VCPKG_TARGET_IS_IOS}
        -Donnxruntime_ENABLE_PYTHON=OFF
        -Donnxruntime_ENABLE_EXTERNAL_CUSTOM_OP_SCHEMAS=OFF
        -Donnxruntime_ENABLE_LAZY_TENSOR=OFF
        -Donnxruntime_NVCC_THREADS=1 # parallel compilation
        -Donnxruntime_DISABLE_RTTI=OFF
        -Donnxruntime_USE_NEURAL_SPEED=OFF
        -DUSE_NEURAL_SPEED=OFF
        # for ORT_BUILD_INFO
        "-DORT_GIT_COMMIT:STRING=v${VERSION}"
        "-DORT_GIT_BRANCH:STRING=v${VERSION}"
    OPTIONS_DEBUG
        -Donnxruntime_ENABLE_MEMLEAK_CHECKER=OFF
        -Donnxruntime_ENABLE_MEMORY_PROFILE=OFF
        -Donnxruntime_DEBUG_NODE_INPUTS_OUTPUTS=1
    MAYBE_UNUSED_VARIABLES
        onnxruntime_BUILD_WEBASSEMBLY
        onnxruntime_TENSORRT_PLACEHOLDER_BUILDER
        onnxruntime_USE_CUSTOM_DIRECTML
        onnxruntime_NVCC_THREADS
        Python_EXECUTABLE
        ORT_GIT_COMMIT
        ORT_GIT_BRANCH
)
vcpkg_cmake_install()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/onnxruntime PACKAGE_NAME onnxruntime)
    vcpkg_fixup_pkgconfig() # pkg_check_modules(libonnxruntime)
endif()

if(("openvino" IN_LIST FEATURES) AND VCPKG_TARGET_IS_WINDOWS)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/onnxruntime_providers_openvino.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/onnxruntime_providers_openvino.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/onnxruntime_providers_openvino.dll" "${CURRENT_PACKAGES_DIR}/bin/onnxruntime_providers_openvino.dll")
endif()
vcpkg_copy_pdbs()

if("framework" IN_LIST FEATURES)
    foreach(FRAMEWORK_NAME "onnxruntime.framework" "onnxruntime_objc.framework")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${FRAMEWORK_NAME}" "${CURRENT_PACKAGES_DIR}/debug/lib/${FRAMEWORK_NAME}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${FRAMEWORK_NAME}" "${CURRENT_PACKAGES_DIR}/lib/${FRAMEWORK_NAME}")
    endforeach()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
