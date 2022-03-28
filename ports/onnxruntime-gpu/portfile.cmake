vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/onnxruntime
    REF  0d9030e79888d1d5828730b254fedc53c7b640c1 # v1.10.0
    SHA512 502b68fae7d2e8441ec26253a9e0cdcf970ab2b61efecee7d964e9880e59d657971a82a666710944617c86d18fa99c2cb9640fcd15f63d05b2617b562a5bdb2f
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-build-issues.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

if ("${VCPKG_HOST_TRIPLET}" STREQUAL "${VCPKG_TARGET_TRIPLET}")
    set(BUILD_HOST ON)
    set(CROSS_BUILD OFF)
else()
    set(BUILD_HOST OFF)
    set(CROSS_BUILD ON)
endif()
string(COMPARE EQUAL "${VCPKG_HOST_TRIPLET}" "${VCPKG_TARGET_TRIPLET}" BUILD_HOST)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_DIR "${PYTHON3}" PATH)
vcpkg_add_to_path(PREPEND "${PYTHON_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        -Donnxruntime_BUILD_SHARED_LIB=${BUILD_SHARED}
        -Donnxruntime_BUILD_FOR_NATIVE_MACHINE=${BUILD_HOST}
        -Donnxruntime_CROSS_COMPILING=${CROSS_BUILD}
        -DCMAKE_INSTALL_INCLUDEDIR=include
        "-DPython_EXECUTABLE=${PYTHON3}"
        -Donnxruntime_RUN_ONNX_TESTS=OFF
        -Donnxruntime_GENERATE_TEST_REPORTS=OFF
        -Donnxruntime_ENABLE_STATIC_ANALYSIS=OFF
        -Donnxruntime_ENABLE_PYTHON=OFF
        -Donnxruntime_ENABLE_MEMLEAK_CHECKER=OFF
        -Donnxruntime_USE_CUDA=OFF
        -Donnxruntime_ENABLE_CUDA_LINE_NUMBER_INFO=OFF
        -Donnxruntime_USE_NNAPI_BUILTIN=OFF
        -Donnxruntime_DEV_MODE=OFF
        -Donnxruntime_BUILD_UNIT_TESTS=OFF
        -Donnxruntime_BUILD_CSHARP=OFF
        -Donnxruntime_BUILD_OBJC=OFF
        -Donnxruntime_USE_PREINSTALLED_EIGEN=ON
        -Donnxruntime_BUILD_BENCHMARKS=OFF
        -Donnxruntime_USE_LLVM=OFF
        -Donnxruntime_USE_AVX=OFF
        -Donnxruntime_USE_AVX2=OFF
        -Donnxruntime_USE_AVX512=OFF
        -Donnxruntime_USE_OPENMP=OFF
        -Donnxruntime_BUILD_APPLE_FRAMEWORK=OFF
        -Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF
        -Donnxruntime_USE_TENSORRT=OFF
        -Donnxruntime_ENABLE_LTO=ON
        -Donnxruntime_DEBUG_NODE_INPUTS_OUTPUTS=OFF
        -Donnxruntime_USE_ROCM=OFF # AMD GPU SUPPORT
        -Donnxruntime_PREFER_SYSTEM_LIB=ON
        -Donnxruntime_MINIMAL_BUILD=ON
        -Donnxruntime_EXTENDED_MINIMAL_BUILD=OFF
        -Donnxruntime_MINIMAL_BUILD_CUSTOM_OPS=OFF
        -Donnxruntime_DISABLE_EXTERNAL_INITIALIZERS=OFF
        -Donnxruntime_USE_VALGRIND=OFF
        -Donnxruntime_RUN_MODELTEST_IN_DEBUG_MODE=OFF
        -Donnxruntime_FUZZ_TEST=OFF
        -Donnxruntime_USE_NCCL=OFF
        -Donnxruntime_USE_MPI=OFF
        -Donnxruntime_ENABLE_BITCODE=OFF
        -Donnxruntime_BUILD_OPSCHEMA_LIB=ON
        -Donnxruntime_USE_EXTENSIONS=OFF
        
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
