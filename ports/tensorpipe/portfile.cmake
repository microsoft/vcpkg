vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(INSTALL_PACKAGE_CONFIG_PATCH
    URLS "https://patch-diff.githubusercontent.com/raw/pytorch/tensorpipe/pull/435.diff"
    FILENAME tensorpipe-pr-435.patch
    SHA512 149539467ddd39feb6e715bf483d67954338998cbbcfef65de5a85831af902165f9347cd097fa8e82b10b2b8dbc388fcfe42664eeaf5de1954ae885f129583ed
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/tensorpipe
    REF 52791a2fd214b2a9dc5759d36725909c1daa7f2e
    SHA512 1e5faf17a7236c5506c08cb28be16069b11bb929bbca64ed9745ce4277d46739186ab7d6597da7437d90ed2d166d4c37ef2f3bceabe8083ef3adbb0e8e5f227e
    PATCHES
        "${INSTALL_PACKAGE_CONFIG_PATCH}"
        use-vcpkg.patch
        support-test.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda        TP_USE_CUDA
        cuda        TP_ENABLE_CUDA_IPC
        pybind11    TP_BUILD_PYTHON
        test        TP_BUILD_TESTING
)

if("pybind11" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND FEATURE_OPTIONS -DPYTHON_EXECUTABLE=${PYTHON3})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTP_ENABLE_SHM=${VCPKG_TARGET_IS_LINUX}
        -DTP_ENABLE_IBV=OFF
        -DTP_ENABLE_CMA=OFF
        -DTP_BUILD_LIBUV=OFF # will use libuv package
        -DTP_ENABLE_CUDA_GDR=OFF
    MAYBE_UNUSED_VARIABLES
        TP_ENABLE_CUDA_GDR
        TP_ENABLE_CUDA_IPC
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/Tensorpipe")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
)
