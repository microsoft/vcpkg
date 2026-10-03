vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO triton-inference-server/core
    REF f1e9f562ed1542cd1a36ddecd691d14c6729f199
    SHA512 49d92264bcd192e9b0cb5b36bb17b073be4429fc3d184a3a956c3f2b4d1e5fed95ccd937fa6395b9d86192e6a45608a35a0f452c2a0852df4d50bdacf7b64534
    HEAD_REF main
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTRITON_CORE_HEADERS_ONLY=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME TritonCore
    CONFIG_PATH lib/cmake/TritonCore
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        "-DTRITON_VERSION=${VERSION}"
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
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
