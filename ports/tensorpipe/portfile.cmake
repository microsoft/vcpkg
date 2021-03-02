vcpkg_fail_port_install(ON_TARGET "windows" "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/tensorpipe
    REF a9aa71a2fe49a8e8475cd5ff16cbd0de13b67c2b
    SHA512 8b2679d4325acc6cd669326504bb49a645c126586b1d61d873d5a0423ed27e7c513574ccd2e74bdd792869167d3daba0804f127e21cfd5831d37a6d1ef7a79ba
    PATCHES
        fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda        TP_USE_CUDA
        cuda        TP_ENABLE_CUDA_IPC
        shm         TP_ENABLE_SHM
        ibv         TP_ENABLE_IBV
        cma         TP_ENABLE_CMA
        pybind11    TP_BUILD_PYTHON
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTP_BUILD_TESTING=OFF -DTP_BUILD_BENCHMARK=OFF -DTP_BUILD_LIBUV=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
