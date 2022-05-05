vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/tensorpipe
    REF c5a21994bc766659f7f85edb75478e13f429f46c
    SHA512 05a3989286610edea2f0fcfb9197c563e947f0386f2b52110dd060053d68b62477fcd4778a45a3030b9a53b6ceccead91e4dd96c9f0153023e97414459fbd8dd
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

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTP_ENABLE_SHM=${VCPKG_TARGET_IS_LINUX}
        -DTP_ENABLE_IBV=OFF
        -DTP_ENABLE_CMA=OFF
        -DTP_BUILD_LIBUV=OFF # will use libuv package
        -DTP_ENABLE_CUDA_GDR=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share
)
