vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO triton-inference-server/server
    REF 819ee37770df2fcd6d799d2a5d1dacf812f7d62c
    SHA512 8eea673fb5aac4da189dd90abe06f7bdc7baada2066a679b6c50d4f675bdf36da4c44940de614cc70e13470d3e2df1236a8dbbb5cdc1600f30beff3a6100a39c
    HEAD_REF main
    PATCHES
        fix-server-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
