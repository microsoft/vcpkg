vcpkg_fail_port_install(ON_TARGET "windows" "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("test" IN_LIST FEATURES)
    list(APPEND FEATURE_PATCHES support-test.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/tensorpipe
    REF f73bcd9dfaa02e8335a493dec7f6b1e3a96aa476
    SHA512 42e144804f491e55a9135c56cc310def905ae1dd84f417237c5035e7ddc90455dd884be7942ca24c678239382d525a5b50c804e29e83919ff84c49c6061e2bea
    PATCHES
        fix-cmakelists.patch
        ${FEATURE_PATCHES}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda        TP_USE_CUDA
        cuda        TP_ENABLE_CUDA_IPC
        shm         TP_ENABLE_SHM
        ibv         TP_ENABLE_IBV
        cma         TP_ENABLE_CMA
        pybind11    TP_BUILD_PYTHON
        test        TP_BUILD_TESTING
        benchmark   TP_BUILD_BENCHMARK
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTP_BUILD_LIBUV=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
