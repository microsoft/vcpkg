vcpkg_fail_port_install(ON_TARGET "windows" "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/tensorpipe
    REF 2aa790fa027246a42abab8a976d4167c71bc09a4
    SHA512 e55597c247267983690d7f1f67c0563ff1374e90d1594cfd733979e1b069d35247578d6dec9734c997a6f7ff58c9753228ec516d9bed0fb46a5c361756c42ac1
    PATCHES
        fix-cmakelists.patch
        support-test.patch
        support-pybind11.patch
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTP_ENABLE_SHM=${VCPKG_TARGET_IS_LINUX}
        -DTP_BUILD_LIBUV=OFF # will use libuv package
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
