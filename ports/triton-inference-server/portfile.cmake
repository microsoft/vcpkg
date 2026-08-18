vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SERVER_SOURCE_PATH
    REPO triton-inference-server/server
    REF 819ee37770df2fcd6d799d2a5d1dacf812f7d62c
    SHA512 8eea673fb5aac4da189dd90abe06f7bdc7baada2066a679b6c50d4f675bdf36da4c44940de614cc70e13470d3e2df1236a8dbbb5cdc1600f30beff3a6100a39c
    HEAD_REF main
    PATCHES
        fix-server-build.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH CORE_SOURCE_PATH
    REPO triton-inference-server/core
    REF f1e9f562ed1542cd1a36ddecd691d14c6729f199
    SHA512 49d92264bcd192e9b0cb5b36bb17b073be4429fc3d184a3a956c3f2b4d1e5fed95ccd937fa6395b9d86192e6a45608a35a0f452c2a0852df4d50bdacf7b64534
    HEAD_REF main
    PATCHES
        fix-core-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CORE_SOURCE_PATH}"
    OPTIONS
        -DTRITON_CORE_HEADERS_ONLY=ON
        -DTRITON_MIN_CXX_STANDARD=17
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME TritonCore
    CONFIG_PATH lib/cmake/TritonCore
)

set(TRITON_CORE_OPTIONS
    -DTRITON_VERSION=${VERSION}
    -DTRITON_MIN_CXX_STANDARD=17
    -DTRITON_ENABLE_LOGGING=ON
    -DTRITON_ENABLE_STATS=ON
    -DTRITON_ENABLE_TRACING=OFF
    -DTRITON_ENABLE_NVTX=OFF
    -DTRITON_ENABLE_GPU=OFF
    -DTRITON_ENABLE_MALI_GPU=OFF
    -DTRITON_ENABLE_ENSEMBLE=OFF
    -DTRITON_ENABLE_METRICS=OFF
    -DTRITON_ENABLE_METRICS_GPU=OFF
    -DTRITON_ENABLE_METRICS_CPU=OFF
    -DTRITON_ENABLE_GCS=OFF
    -DTRITON_ENABLE_S3=OFF
    -DTRITON_ENABLE_AZURE_STORAGE=OFF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CORE_SOURCE_PATH}/src"
    OPTIONS ${TRITON_CORE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_configure(
    SOURCE_PATH "${SERVER_SOURCE_PATH}/src"
    OPTIONS
        "-DTritonCore_DIR=${CURRENT_PACKAGES_DIR}/share/TritonCore"
        -DTRITON_MIN_CXX_STANDARD=17
        -DTRITON_ENABLE_EXAMPLES=OFF
        -DTRITON_ENABLE_LOGGING=ON
        -DTRITON_ENABLE_STATS=ON
        -DTRITON_ENABLE_TRACING=OFF
        -DTRITON_ENABLE_NVTX=OFF
        -DTRITON_ENABLE_GPU=OFF
        -DTRITON_ENABLE_HTTP=ON
        -DTRITON_ENABLE_GRPC=ON
        -DTRITON_ENABLE_SAGEMAKER=OFF
        -DTRITON_ENABLE_VERTEX_AI=OFF
        -DTRITON_ENABLE_METRICS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES tritonserver AUTO_CLEAN)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SERVER_SOURCE_PATH}/LICENSE"
        "${CORE_SOURCE_PATH}/LICENSE"
)
